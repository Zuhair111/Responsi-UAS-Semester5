import 'package:flutter/material.dart';
import 'package:responsi/services/auth_service.dart';
import 'package:responsi/services/follow_service.dart';
import 'user_profile_page.dart';

class FollowListPage extends StatefulWidget {
  final String type; // 'followers' atau 'following'

  const FollowListPage({Key? key, required this.type}) : super(key: key);

  @override
  _FollowListPageState createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  bool _isGridView = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  final AuthService _authService = AuthService();
  final FollowService _followService = FollowService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No current user');
        setState(() => _isLoading = false);
        return;
      }

      print('👤 Loading ${widget.type} for user: $currentUserId');

      List<Map<String, dynamic>> users;
      if (widget.type == 'followers') {
        users = await _followService.getFollowers(currentUserId);
      } else {
        users = await _followService.getFollowing(currentUserId);
      }

      print('✅ Loaded ${users.length} ${widget.type}');
      print('📊 Users data: $users');

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow(String userId, bool isCurrentlyFollowing) async {
    try {
      if (isCurrentlyFollowing) {
        await _followService.unfollowUser(userId);
      } else {
        await _followService.followUser(userId);
      }
      // Reload the list
      _loadUsers();
    } catch (e) {
      print('Error toggling follow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update follow status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFollowers = widget.type == 'followers';
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            isFollowers ? 'Followers' : 'Following',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : Column(
              children: [
                // Tabs Followers / Following
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!isFollowers) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FollowListPage(type: 'followers')),
                            );
                          }
                        },
                        child: Text(
                          'Followers',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: isFollowers ? Colors.orange : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          if (isFollowers) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FollowListPage(type: 'following')),
                            );
                          }
                        },
                        child: Text(
                          'Following',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: !isFollowers ? Colors.orange : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Header + tombol layout
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_users.length} ${isFollowers ? "Followers" : "Following"}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.grid_view_rounded,
                                color:
                                    _isGridView ? Colors.orange : Colors.grey),
                            onPressed: () => setState(() => _isGridView = true),
                          ),
                          IconButton(
                            icon: Icon(Icons.list,
                                color:
                                    !_isGridView ? Colors.orange : Colors.grey),
                            onPressed: () =>
                                setState(() => _isGridView = false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (_users.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            isFollowers
                                ? 'No followers yet'
                                : 'Not following anyone yet',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_users.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _isGridView
                          ? GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3 / 2.5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                final profile = isFollowers
                                    ? user['profiles']
                                    : user['profiles'];
                                    
                                if (profile == null) return SizedBox.shrink();
                                
                                final userId = isFollowers
                                    ? user['follower_id']
                                    : user['following_id'];
                                final userName =
                                    profile['username'] ?? profile['full_name'] ?? 'Unknown';
                                final avatarUrl = profile['avatar_url'];

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfilePage(
                                          userId: userId,
                                          username: userName,
                                        ),
                                      ),
                                    ).then((_) => _loadUsers());
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.orange),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: avatarUrl != null
                                              ? NetworkImage(avatarUrl)
                                              : null,
                                          radius: 28,
                                          child: avatarUrl == null
                                              ? Icon(Icons.person,
                                                  color: Colors.grey)
                                              : null,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(userName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        const SizedBox(height: 6),
                                        if (!isFollowers)
                                          OutlinedButton(
                                            onPressed: () =>
                                                _toggleFollow(userId, true),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                  color: Colors.orange),
                                              foregroundColor: Colors.orange,
                                              minimumSize: const Size(90, 28),
                                            ),
                                            child: Text(
                                              "UNFOLLOW",
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final user = _users[index];
                                final profile = isFollowers
                                    ? user['profiles']
                                    : user['profiles'];
                                    
                                if (profile == null) return SizedBox.shrink();
                                
                                final userId = isFollowers
                                    ? user['follower_id']
                                    : user['following_id'];
                                final userName =
                                    profile['username'] ?? profile['full_name'] ?? 'Unknown';
                                final avatarUrl = profile['avatar_url'];

                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfilePage(
                                          userId: userId,
                                          username: userName,
                                        ),
                                      ),
                                    ).then((_) => _loadUsers());
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: avatarUrl != null
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    radius: 25,
                                    child: avatarUrl == null
                                        ? Icon(Icons.person, color: Colors.grey)
                                        : null,
                                  ),
                                  title: Text(userName),
                                  trailing: !isFollowers
                                      ? OutlinedButton(
                                          onPressed: () =>
                                              _toggleFollow(userId, true),
                                          style: OutlinedButton.styleFrom(
                                            side:
                                                BorderSide(color: Colors.orange),
                                            foregroundColor: Colors.orange,
                                          ),
                                          child: Text("UNFOLLOW"),
                                        )
                                      : null,
                                );
                              },
                            ),
                    ),
                  ),
              ],
            ),
    );
  }
}