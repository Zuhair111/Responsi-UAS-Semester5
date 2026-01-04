import 'package:flutter/material.dart';
import 'package:responsi/services/auth_service.dart';
import 'package:responsi/services/follow_service.dart';
import 'package:responsi/services/post_service.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';
import 'user_posts_page.dart';
import 'chat_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String? username;

  const UserProfilePage({
    Key? key,
    required this.userId,
    this.username,
  }) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isGridView = true;
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isFollowLoading = false;
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _userPosts = [];
  int _followerCount = 0;
  int _followingCount = 0;

  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  final FollowService _followService = FollowService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      print('Loading profile for user: ${widget.userId}');

      // Load user profile
      final profile = await _authService.getUserProfile(widget.userId);
      print('Profile loaded: $profile');

      if (profile == null) {
        print('Error: Profile is null');
        setState(() => _isLoading = false);
        return;
      }

      // Load user posts
      final postsResponse = await _postService.getUserPosts(widget.userId);
      final posts = postsResponse
          .map(
            (post) => {
              'id': post.id,
              'content': post.content,
              'image_url': post.imageUrl,
              'likes_count': post.likesCount,
              'comments_count': post.commentsCount,
            },
          )
          .toList();

      // Load follow stats
      final isFollowing = await _followService.isFollowing(widget.userId);
      final followerCount = await _followService.getFollowerCount(widget.userId);
      final followingCount = await _followService.getFollowingCount(widget.userId);

      setState(() {
        _userProfile = profile;
        _userPosts = posts;
        _isFollowing = isFollowing;
        _followerCount = followerCount;
        _followingCount = followingCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _isFollowLoading = true);

    try {
      bool success;
      if (_isFollowing) {
        success = await _followService.unfollowUser(widget.userId);
        if (success) {
          setState(() {
            _isFollowing = false;
            _followerCount--;
          });
        }
      } else {
        success = await _followService.followUser(widget.userId);
        if (success) {
          setState(() {
            _isFollowing = true;
            _followerCount++;
          });
        }
      }

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${_isFollowing ? 'unfollow' : 'follow'} user')),
        );
      }
    } catch (e) {
      print('Error toggling follow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      setState(() => _isFollowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.username ?? 'Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Unable to load profile'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final username = _userProfile!['username'] ?? 'Unknown';
    final fullName = _userProfile!['full_name'] ?? '';
    final bio = _userProfile!['bio'] ?? '';
    final avatarUrl = _userProfile!['avatar_url'];
    final postsCount = _userPosts.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          username,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Icon(Icons.person, size: 40, color: Colors.grey)
                              : null,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn(postsCount.toString(), 'Posts'),
                              _buildStatColumn(_followerCount.toString(), 'Followers'),
                              _buildStatColumn(_followingCount.toString(), 'Following'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (fullName.isNotEmpty)
                          Text(
                            fullName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (bio.isNotEmpty) SizedBox(height: 4),
                        if (bio.isNotEmpty) Text(bio),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _isFollowLoading
                              ? Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                      ),
                                    ),
                                  ),
                                )
                              : OutlinedButton(
                                  onPressed: _toggleFollow,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _isFollowing ? Colors.white : Colors.blue,
                                    foregroundColor: _isFollowing ? Colors.black : Colors.white,
                                    side: BorderSide(color: _isFollowing ? Colors.grey : Colors.blue),
                                  ),
                                  child: Text(_isFollowing ? 'Following' : 'Follow'),
                                ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    otherUserId: widget.userId,
                                    otherUsername: username,
                                    otherUserAvatar: avatarUrl,
                                  ),
                                ),
                              );
                            },
                            child: Text('Message'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(height: 1),
                  Row(
                    children: [
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.grid_on,
                            color: _isGridView ? Colors.black : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = true;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.view_list,
                            color: !_isGridView ? Colors.black : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 1),
                ],
              ),
            ),
            if (_userPosts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No posts yet',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGridView)
              SliverPadding(
                padding: EdgeInsets.all(2),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = _userPosts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserPostsPage(
                                userId: widget.userId,
                                userName: username,
                                initialIndex: index,
                              ),
                            ),
                          ).then((_) => _loadUserData());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            image: post['image_url'] != null
                                ? DecorationImage(
                                    image: NetworkImage(post['image_url']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: post['image_url'] == null
                              ? Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey[600]),
                                )
                              : null,
                        ),
                      );
                    },
                    childCount: _userPosts.length,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final postData = _userPosts[index];
                    final post = PostModel(
                      id: postData['id'] as String? ?? '',
                      userId: widget.userId,
                      userName: username,
                      userAvatarUrl: avatarUrl,
                      content: postData['content'] as String? ?? '',
                      imageUrl: postData['image_url'] as String?,
                      privacy: 'public',
                      likesCount: (postData['likes_count'] as num?)?.toInt() ?? 0,
                      commentsCount: (postData['comments_count'] as num?)?.toInt() ?? 0,
                      createdAt: DateTime.now(),
                    );

                    return AbsorbPointer(
                      child: PostCard(
                        post: post,
                        onDelete: () {},
                      ),
                    );
                  },
                  childCount: _userPosts.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
