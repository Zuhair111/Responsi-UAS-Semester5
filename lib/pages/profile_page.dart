import 'package:flutter/material.dart';
import 'package:responsi/pages/following_page.dart';
import 'package:responsi/services/auth_service.dart';
import 'package:responsi/services/follow_service.dart';
import 'package:responsi/services/post_service.dart';
import '../models/post_model.dart';
import '../widgets/post_card.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'user_posts_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isGridView = true;
  bool _isLoading = true;
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
      // Check if user is logged in
      if (_authService.currentUser == null) {
        print('Error: User not logged in');
        setState(() => _isLoading = false);
        return;
      }

      print('Loading profile for user: ${_authService.currentUser!.id}');

      // Load user profile
      final profile = await _authService.getCurrentUserProfile();
      print('Profile loaded: $profile');

      if (profile == null) {
        print('Error: Profile is null');
        setState(() => _isLoading = false);
        return;
      }

      // Load user posts (convert to raw data)
      final postsResponse = await _postService.getUserPosts(
        _authService.currentUser!.id,
      );
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
      final followerCount = await _followService.getFollowerCount(_authService.currentUser!.id);
      final followingCount = await _followService.getFollowingCount(_authService.currentUser!.id);

      setState(() {
        _userProfile = profile;
        _userPosts = posts;
        _followerCount = followerCount;
        _followingCount = followingCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      print('Error stacktrace: ${StackTrace.current}');
      setState(() => _isLoading = false);
    }
  }

  final List<String> posts = [
    'https://picsum.photos/400/600?random=40',
    'https://picsum.photos/400/400?random=41',
    'https://picsum.photos/400/500?random=42',
    'https://picsum.photos/400/600?random=43',
    'https://picsum.photos/400/400?random=44',
    'https://picsum.photos/400/500?random=45',
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (_userProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _authService.currentUser == null
                    ? 'Please login first'
                    : 'Profile data not found. Please make sure:\n1. You have run the SQL migration\n2. Profile was created on signup',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          floating: true,
          pinned: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.orange,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${_userProfile!['username'] ?? 'username'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _userProfile!['name'] ?? 'User',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _userProfile!['bio'] ?? 'No bio yet',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange, width: 3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child:
                                _userProfile!['avatar_url'] != null &&
                                    _userProfile!['avatar_url'].isNotEmpty
                                ? Image.network(
                                    _userProfile!['avatar_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(),
                                ),
                              );
                              if (result == true) {
                                _loadUserData();
                              }
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // About Me
                Text(
                  'About me',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  _userProfile!['bio'] ?? 'No bio yet',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 20),

                // Stats Container
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF6C5CE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(_userPosts.length.toString(), 'Post'),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FollowListPage(type: 'followers'),
                            ),
                          );
                        },
                        child: _buildStatItem(_followerCount.toString(), 'Followers'),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FollowListPage(type: 'following'),
                            ),
                          );
                        },
                        child: _buildStatItem(_followingCount.toString(), 'Following'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                // My Posts Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Posts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.grid_view_rounded,
                            color: _isGridView ? Colors.orange : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = true;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.list,
                            color: !_isGridView ? Colors.orange : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // Posts Grid
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          sliver: _isGridView ? _buildGridView() : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildGridView() {
    if (_userPosts.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final post = _userPosts[index];
        final imageUrl = post['image_url'] ?? posts[index % posts.length];

        return GestureDetector(
          onTap: () {
            // Navigasi ke halaman user posts dengan index yang diklik
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserPostsPage(
                  userId: _userProfile?['id'] ?? '',
                  userName: _userProfile?['name'] ?? 'User',
                  initialIndex: index,
                ),
              ),
            ).then((_) => _loadUserData()); // Refresh setelah kembali
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                );
              },
            ),
          ),
        );
      }, childCount: _userPosts.length),
    );
  }

  Widget _buildListView() {
    if (_userPosts.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final postData = _userPosts[index];
        
        // Convert post data to PostModel
        final post = PostModel(
          id: postData['id']?.toString() ?? '',
          userId: postData['user_id']?.toString() ?? '',
          userName: postData['profiles']?['name'] ?? 'Unknown',
          userAvatarUrl: postData['profiles']?['avatar_url'],
          imageUrl: postData['image_url'],
          content: postData['caption']?.toString() ?? '',
          privacy: postData['privacy']?.toString() ?? 'public',
          likesCount: postData['likes_count'] ?? 0,
          commentsCount: postData['comments_count'] ?? 0,
          createdAt: postData['created_at'] != null 
              ? DateTime.parse(postData['created_at']) 
              : DateTime.now(),
        );

        return GestureDetector(
          onTap: () {
            // Navigasi ke halaman user posts dengan index yang diklik
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserPostsPage(
                  userId: _userProfile?['id'] ?? '',
                  userName: _userProfile?['name'] ?? 'User',
                  initialIndex: index,
                ),
              ),
            ).then((_) => _loadUserData()); // Refresh setelah kembali
          },
          child: AbsorbPointer(
            // Disable interaction pada PostCard agar tap hanya ke parent
            child: PostCard(
              post: post,
              onDelete: () {
                print('🔄 Removing post from profile UI: ${postData['id']}');
                // Langsung remove dari list tanpa reload
                setState(() {
                  _userPosts.removeWhere((p) => p['id'] == postData['id']);
                  print('✅ Posts remaining: ${_userPosts.length}');
                });
              },
            ),
          ),
        );
      }, childCount: _userPosts.length),
    );
  }
}
