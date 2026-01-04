import 'package:flutter/material.dart';
import 'package:responsi/services/follow_service.dart';
import 'package:responsi/services/chat_service.dart';
import 'package:responsi/services/auth_service.dart';

class SharePostDialog extends StatefulWidget {
  final String postId;
  final String postContent;
  final String? postImageUrl;

  const SharePostDialog({
    Key? key,
    required this.postId,
    required this.postContent,
    this.postImageUrl,
  }) : super(key: key);

  @override
  _SharePostDialogState createState() => _SharePostDialogState();
}

class _SharePostDialogState extends State<SharePostDialog> {
  final FollowService _followService = FollowService();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _following = [];
  List<Map<String, dynamic>> _filteredFollowing = [];
  bool _isLoading = true;
  Set<String> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowing() async {
    setState(() => _isLoading = true);

    try {
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final followingResponse = await _followService.getFollowing(currentUserId);
      
      // Extract profile data from nested structure
      final following = followingResponse.map((item) {
        final profile = item['profiles'] as Map<String, dynamic>;
        return profile;
      }).toList();
      
      setState(() {
        _following = following;
        _filteredFollowing = following;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading following: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterFollowing(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFollowing = _following;
      });
    } else {
      setState(() {
        _filteredFollowing = _following.where((user) {
          final username = user['username']?.toString().toLowerCase() ?? '';
          final name = user['name']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return username.contains(searchLower) || name.contains(searchLower);
        }).toList();
      });
    }
  }

  Future<void> _sharePost() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );

    try {
      int successCount = 0;
      
      for (String userId in _selectedUsers) {
        // Get or create conversation
        final conversationId = await _chatService.getOrCreateConversation(userId);
        
        if (conversationId != null) {
          // Send post as message
          final success = await _chatService.sendPostMessage(
            conversationId,
            userId,
            widget.postId,
            widget.postContent,
          );
          
          if (success) successCount++;
        }
      }

      // Close loading dialog
      Navigator.pop(context);

      if (successCount > 0) {
        // Close share dialog
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post shared to $successCount user(s)'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share post')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      print('Error sharing post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Share Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            
            // Search bar
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onChanged: _filterFollowing,
              ),
            ),

            // User list
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.orange))
                  : _filteredFollowing.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                _following.isEmpty
                                    ? 'You are not following anyone'
                                    : 'No users found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredFollowing.length,
                          itemBuilder: (context, index) {
                            final user = _filteredFollowing[index];
                            final userId = user['id'] as String;
                            final username = user['username'] ?? 'Unknown';
                            final name = user['name'] ?? '';
                            final avatarUrl = user['avatar_url'] as String?;
                            final isSelected = _selectedUsers.contains(userId);

                            return CheckboxListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedUsers.add(userId);
                                  } else {
                                    _selectedUsers.remove(userId);
                                  }
                                });
                              },
                              activeColor: Colors.blue,
                              secondary: CircleAvatar(
                                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl == null || avatarUrl.isEmpty
                                    ? Icon(Icons.person, color: Colors.grey)
                                    : null,
                              ),
                              title: Text(
                                username,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: name.isNotEmpty ? Text(name) : null,
                            );
                          },
                        ),
            ),

            // Footer
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '${_selectedUsers.length} selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _selectedUsers.isEmpty ? null : _sharePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Send',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
