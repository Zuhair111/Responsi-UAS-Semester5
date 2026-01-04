import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../pages/reel_comments_page.dart';
import '../services/follow_service.dart';
import '../services/auth_service.dart';
import '../pages/user_profile_page.dart';

class ReelItem extends StatefulWidget {
  final Map<String, dynamic> reelData;
  final int index;
  final bool isCurrentPage;
  final VoidCallback onLikeToggle;
  final VoidCallback? onCreateReel;
  final Function(int newCount)? onCommentsUpdated;

  const ReelItem({
    Key? key,
    required this.reelData,
    required this.index,
    required this.isCurrentPage,
    required this.onLikeToggle,
    this.onCreateReel,
    this.onCommentsUpdated,
  }) : super(key: key);

  @override
  _ReelItemState createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  final FollowService _followService = FollowService();
  final AuthService _authService = AuthService();
  bool _isFollowing = false;
  String? _currentUserId;
  bool _isLoadingFollow = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadFollowStatus();
  }

  Future<void> _loadFollowStatus() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.id;
      });
      
      final userId = widget.reelData['userId'];
      if (userId != null && userId != _currentUserId) {
        final isFollowing = await _followService.isFollowing(userId);
        if (mounted) {
          setState(() {
            _isFollowing = isFollowing;
            _isLoadingFollow = false;
          });
        }
      } else {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  Future<void> _handleFollowToggle() async {
    final userId = widget.reelData['userId'];
    if (userId == null) return;

    setState(() {
      _isFollowing = !_isFollowing;
    });

    final success = _isFollowing
        ? await _followService.followUser(userId)
        : await _followService.unfollowUser(userId);

    if (!success) {
      // Revert on failure
      setState(() {
        _isFollowing = !_isFollowing;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${_isFollowing ? "follow" : "unfollow"} user')),
        );
      }
    }
  }

  void _navigateToProfile() {
    final userId = widget.reelData['userId'];
    final userName = widget.reelData['userName'];
    
    if (userId != null && userId != _currentUserId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(
            userId: userId,
            username: userName,
          ),
        ),
      );
    }
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.network(widget.reelData['videoUrl'])
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.isCurrentPage) {
          _controller.play();
          _controller.setLooping(true);
          setState(() {
            _isPlaying = true;
          });
        }
      }).catchError((error) {
        print('Error initializing video: $error');
      });
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _controller.play();
      _controller.setLooping(true);
      setState(() {
        _isPlaying = true;
      });
    } else if (!widget.isCurrentPage && oldWidget.isCurrentPage) {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        children: [
          if (_isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
                Text(
                  'Reels',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 28), // Placeholder untuk symmetry
              ],
            ),
          ),
          if (!_isPlaying)
            Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white.withOpacity(0.7),
                size: 80,
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _navigateToProfile,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundImage:
                                    NetworkImage(widget.reelData['userImage']),
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: _navigateToProfile,
                              child: Text(
                                widget.reelData['userName'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            // Only show follow button if not own reel
                            if (widget.reelData['userId'] != _currentUserId && !_isLoadingFollow) ...[
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: _handleFollowToggle,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _isFollowing ? Colors.white : Colors.transparent,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    _isFollowing ? 'Unfollow' : 'Follow',
                                    style: TextStyle(
                                      color: _isFollowing ? Colors.black : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.reelData['description'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        icon: widget.reelData['isLiked']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        label: _formatNumber(widget.reelData['likes']),
                        color: widget.reelData['isLiked']
                            ? Colors.red
                            : Colors.white,
                        onTap: widget.onLikeToggle,
                      ),
                      SizedBox(height: 25),
                      _buildActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: _formatNumber(widget.reelData['comments']),
                        color: Colors.white,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReelCommentsPage(
                                reelId: widget.reelData['id'],
                                initialCommentsCount: widget.reelData['comments'],
                              ),
                            ),
                          );
                          // Update comments count if changed
                          if (result is int && widget.onCommentsUpdated != null) {
                            widget.onCommentsUpdated!(result);
                          }
                        },
                      ),
                      SizedBox(height: 25),
                      _buildActionButton(
                        icon: Icons.send_outlined,
                        label: widget.reelData['shares'] > 0 
                            ? _formatNumber(widget.reelData['shares'])
                            : '',
                        color: Colors.white,
                        onTap: () => _handleShare(context),
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _handleShare(BuildContext context) async {
    try {
      final reelUrl = widget.reelData['videoUrl'] ?? '';
      final caption = widget.reelData['description'] ?? '';
      final userName = widget.reelData['userName'] ?? '';
      
      // Show share options
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Share Reel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Link'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: reelUrl));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share via...'),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(
                    'Check out this reel by $userName!\n\n$caption\n\n$reelUrl',
                    subject: 'Reel by $userName',
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}