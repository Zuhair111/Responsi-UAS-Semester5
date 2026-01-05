import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/reel_item.dart';
import '../services/reel_service.dart';
import '../models/reel_model.dart';
import 'create_reel_page.dart';

class ReelsPage extends StatefulWidget {
  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final PageController _pageController = PageController();
  final ReelService _reelService = ReelService();
  int currentPage = 0;
  List<ReelModel> _reels = [];
  bool _isLoading = true;

  // Real-time subscription channels
  RealtimeChannel? _reelsChannel;
  RealtimeChannel? _reelsUpdatesChannel;
  RealtimeChannel? _reelsDeletionsChannel;

  @override
  void initState() {
    super.initState();
    _loadReels();
    _setupRealtimeSubscriptions();
  }

  void _setupRealtimeSubscriptions() {
    // Subscribe to new reels
    _reelsChannel = _reelService.subscribeToNewReels((newReelData) {
      if (mounted) {
        setState(() {
          // Add new reel to the beginning of the list
          final newReel = ReelModel.fromMap(newReelData);
          _reels.insert(0, newReel);
        });
        
        // Show notification snackbar for new reel
        final username = newReelData['profiles']?['username'] ?? newReelData['profiles']?['name'] ?? 'Someone';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎥 New reel from $username'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF4A3E9E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // Subscribe to reel updates (likes)
    _reelsUpdatesChannel = _reelService.subscribeToReelUpdates((updatedReelData) {
      if (mounted) {
        setState(() {
          final index = _reels.indexWhere((reel) => reel.id == updatedReelData['id']);
          if (index != -1) {
            // Update the reel with new likes count
            _reels[index] = _reels[index].copyWith(
              likesCount: updatedReelData['likes_count'] ?? _reels[index].likesCount,
              commentsCount: updatedReelData['comments_count'] ?? _reels[index].commentsCount,
            );
          }
        });
      }
    });

    // Subscribe to reel deletions
    _reelsDeletionsChannel = _reelService.subscribeToReelDeletions((deletedReelId) {
      if (mounted) {
        setState(() {
          _reels.removeWhere((reel) => reel.id == deletedReelId);
        });
      }
    });

    print('✅ Real-time reels subscriptions setup completed');
  }

  Future<void> _cleanupSubscriptions() async {
    if (_reelsChannel != null) {
      await _reelService.unsubscribeFromChannel(_reelsChannel!);
    }
    if (_reelsUpdatesChannel != null) {
      await _reelService.unsubscribeFromChannel(_reelsUpdatesChannel!);
    }
    if (_reelsDeletionsChannel != null) {
      await _reelService.unsubscribeFromChannel(_reelsDeletionsChannel!);
    }
    print('✅ Real-time reels subscriptions cleaned up');
  }

  Future<void> _loadReels() async {
    setState(() => _isLoading = true);
    try {
      final reels = await _reelService.getReels();
      if (mounted) {
        setState(() {
          _reels = reels;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reels: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLikeToggle(int index) async {
    final reel = _reels[index];
    final isLiked = reel.isLiked ?? false;

    // Optimistic update
    setState(() {
      _reels[index] = reel.copyWith(
        isLiked: !isLiked,
        likesCount: isLiked ? reel.likesCount - 1 : reel.likesCount + 1,
      );
    });

    // Send to server
    final success = isLiked
        ? await _reelService.unlikeReel(reel.id)
        : await _reelService.likeReel(reel.id);

    // If failed, revert
    if (!success) {
      setState(() {
        _reels[index] = reel;
      });
    }
  }

  void _handleCommentsUpdated(int index, int newCount) {
    setState(() {
      _reels[index] = _reels[index].copyWith(
        commentsCount: newCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : _reels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 80,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No reels yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first reel!',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateReelPage(),
                            ),
                          );
                          if (result == true) {
                            _loadReels();
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text('Create Reel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4A3E9E),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _reels.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                    // Add view when user views a reel
                    _reelService.addReelView(_reels[index].id);
                  },
                  itemBuilder: (context, index) {
                    final reel = _reels[index];
                    return ReelItem(
                      reelData: {
                        'id': reel.id,
                        'userId': reel.userId,
                        'userName': reel.userName,
                        'userImage': reel.userAvatarUrl ??
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop',
                        'videoUrl': reel.videoUrl,
                        'description': reel.caption ?? '',
                        'likes': reel.likesCount,
                        'comments': reel.commentsCount,
                        'shares': 0,
                        'views': reel.viewsCount,
                        'isLiked': reel.isLiked ?? false,
                      },
                      index: index,
                      isCurrentPage: currentPage == index,
                      onLikeToggle: () => _handleLikeToggle(index),
                      onCommentsUpdated: (newCount) => _handleCommentsUpdated(index, newCount),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _cleanupSubscriptions();
    _pageController.dispose();
    super.dispose();
  }
}