import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/post_service.dart';
import '../services/supabase_service.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String postOwnerId;

  const CommentsPage({
    Key? key,
    required this.postId,
    required this.postOwnerId,
  }) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  Map<String, dynamic>? _post;
  bool _isLoading = true;
  String? _replyingTo;
  String? _replyingToName;
  String? _parentCommentId;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      final response = await SupabaseService.client
          .from('posts')
          .select('''
            *,
            profiles!posts_user_id_fkey(id, username, full_name, avatar_url)
          ''')
          .eq('id', widget.postId)
          .single();
      
      if (mounted) {
        setState(() {
          _post = response;
        });
      }
    } catch (e) {
      print('Error loading post: $e');
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments = await _postService.getComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final success = await _postService.addComment(
      postId: widget.postId,
      content: _commentController.text.trim(),
      parentCommentId: _parentCommentId,
    );

    if (success) {
      _commentController.clear();
      setState(() {
        _replyingTo = null;
        _replyingToName = null;
        _parentCommentId = null;
      });
      _loadComments();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add comment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setReplyTo(String commentId, String userName) {
    setState(() {
      _replyingTo = commentId;
      _replyingToName = userName;
      _parentCommentId = commentId;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      _replyingToName = null;
      _parentCommentId = null;
    });
  }

  Widget _buildComment(Map<String, dynamic> comment, {bool isReply = false}) {
    final profile = comment['profiles'];
    final userName = profile?['name'] ?? 'Unknown';
    final userAvatar = profile?['avatar_url'];
    final content = comment['content'] ?? '';
    final createdAt = DateTime.parse(comment['created_at']);
    final timeAgo = _formatTimeAgo(createdAt);
    final commentUserId = comment['user_id'];
    final currentUserId = SupabaseService.currentUser?.id;
    final isPostOwner = commentUserId == widget.postOwnerId;
    final isCurrentUser = commentUserId == currentUserId;
    
    // Get replies for this comment
    final replies = _comments.where((c) => c['parent_comment_id'] == comment['id']).toList();

    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 40 : 0,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: isReply ? 16 : 20,
                backgroundImage: userAvatar != null ? NetworkImage(userAvatar) : null,
                child: userAvatar == null
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isReply ? 14 : 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Comment content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPostOwner 
                        ? Colors.orange.withOpacity(0.1) 
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: isPostOwner 
                        ? Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isReply ? 13 : 14,
                              color: isPostOwner ? Colors.orange[800] : Colors.black,
                            ),
                          ),
                          if (isPostOwner) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Author',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: isReply ? 13 : 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Delete button for own comments
              if (isCurrentUser)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.grey,
                  onPressed: () => _deleteComment(comment['id']),
                ),
            ],
          ),
          
          // Action buttons
          Padding(
            padding: EdgeInsets.only(left: isReply ? 48 : 52, top: 4),
            child: Row(
              children: [
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                if (!isReply)
                  GestureDetector(
                    onTap: () => _setReplyTo(comment['id'], userName),
                    child: const Text(
                      'Reply',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Display replies
          if (replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...replies.map((reply) => _buildComment(reply, isReply: true)).toList(),
          ],
        ],
      ),
    );
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _postService.deleteComment(commentId, widget.postId);
      if (success) {
        _loadComments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment deleted'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'en_short');
  }

  Widget _buildPostSection() {
    final profile = _post!['profiles'];
    final username = profile?['username'] ?? profile?['full_name'] ?? 'Unknown';
    final avatarUrl = profile?['avatar_url'];
    final imageUrl = _post!['image_url'];
    final content = _post!['content'] ?? '';
    final createdAt = DateTime.parse(_post!['created_at']);
    final timeAgo = _formatTimeAgo(createdAt);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          username.isNotEmpty ? username[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post image
          if (imageUrl != null)
            Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

          // Post caption
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: '$username ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: content),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter to show only top-level comments (no parent)
    final topLevelComments = _comments.where((c) => c['parent_comment_id'] == null).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Post display
          if (_post != null) _buildPostSection(),
          const Divider(height: 1, thickness: 1),
          
          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : topLevelComments.isEmpty
                    ? const Center(
                        child: Text(
                          'No comments yet.\nBe the first to comment!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: topLevelComments.length,
                        itemBuilder: (context, index) {
                          return _buildComment(topLevelComments[index]);
                        },
                      ),
          ),
          
          // Reply indicator
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to $_replyingToName',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _cancelReply,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          
          const Divider(height: 1),
          
          // Comment input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: SupabaseService.currentUser != null
                        ? null
                        : null,
                    child: Text(
                      SupabaseService.currentUser?.email?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _replyingTo != null ? 'Write a reply...' : 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.orange),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
