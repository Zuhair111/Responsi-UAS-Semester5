import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../pages/user_profile_page.dart';
import '../services/post_service.dart';
import '../services/supabase_service.dart';
import 'share_post_dialog.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const PostCard({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onDelete,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostService _postService = PostService();
  bool _isLiked = false;
  int _likesCount = 0;
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    _commentsCount = widget.post.commentsCount;
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final liked = await _postService.isPostLiked(widget.post.id);
    if (mounted) {
      setState(() => _isLiked = liked);
    }
  }

  Future<void> _handleLike() async {
    // Optimistic update - langsung update UI
    final wasLiked = _isLiked;
    final wasLikesCount = _likesCount;

    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    // Update ke server di background
    final result = await _postService.likePost(widget.post.id);

    // Jika gagal, revert ke state sebelumnya
    if (result != _isLiked && mounted) {
      setState(() {
        _isLiked = wasLiked;
        _likesCount = wasLikesCount;
      });
    }

    // TIDAK memanggil widget.onLike?.call() untuk menghindari rebuild parent
  }

  void _handleShare() {
    showDialog(
      context: context,
      builder: (context) => SharePostDialog(
        postId: widget.post.id,
        postContent: widget.post.content,
        postImageUrl: widget.post.imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    print('🖱️ Avatar tapped! User ID: ${widget.post.userId}');
                    final currentUserId = SupabaseService.client.auth.currentUser?.id;
                    print('🔍 Current user ID: $currentUserId');
                    if (currentUserId != widget.post.userId) {
                      print('✅ Navigating to profile page');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(
                            userId: widget.post.userId,
                            username: widget.post.userName,
                          ),
                        ),
                      );
                    } else {
                      print('⚠️ Same user, not navigating');
                    }
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.post.userAvatarUrl != null
                        ? NetworkImage(widget.post.userAvatarUrl!)
                        : null,
                    child: widget.post.userAvatarUrl == null
                        ? Text(
                            widget.post.userName.isNotEmpty
                                ? widget.post.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      print('🖱️ Username tapped! User ID: ${widget.post.userId}');
                      final currentUserId = SupabaseService.client.auth.currentUser?.id;
                      print('🔍 Current user ID: $currentUserId');
                      if (currentUserId != widget.post.userId) {
                        print('✅ Navigating to profile page');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePage(
                              userId: widget.post.userId,
                              username: widget.post.userName,
                            ),
                          ),
                        );
                      } else {
                        print('⚠️ Same user, not navigating');
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.post.timeAgo,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    _showPostOptions(context);
                  },
                ),
              ],
            ),
          ),

          // Post Content
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                widget.post.content,
                style: const TextStyle(fontSize: 14),
              ),
            ),

          // Post Image
          if (widget.post.imageUrl != null)
            Image.network(
              widget.post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
            ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildActionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '$_likesCount',
                  color: _isLiked ? Colors.red : Colors.grey[700],
                  onTap: _handleLike,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: '$_commentsCount',
                  onTap: widget.onComment,
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: _handleShare,
                ),
              ],
            ),
          ),

          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color ?? Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context) async {
    final currentUser = SupabaseService.client.auth.currentUser;
    final isOwner = currentUser?.id == widget.post.userId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Post',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save Post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Post saved')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Link copied')));
              },
            ),
            if (!isOwner)
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePost(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(BuildContext context) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Deleting post...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final success = await _postService.deletePost(widget.post.id);

    print('📊 Delete result: success=$success, context.mounted=${context.mounted}');

    // Call onDelete callback regardless of context.mounted
    if (success) {
      print('✅ Delete success, calling onDelete callback...');
      if (widget.onDelete != null) {
        print('🔔 onDelete callback exists, calling it now');
        widget.onDelete!();
      } else {
        print('⚠️ onDelete callback is NULL!');
      }
    }

    // Show UI feedback only if context is still mounted
    if (context.mounted) {
      print('🔍 Context is mounted, showing feedback...');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete post'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
