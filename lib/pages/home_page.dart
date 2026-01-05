import 'package:flutter/material.dart';
import 'package:responsi/pages/sign_in_screen.dart';
import 'package:responsi/pages/welcome_page.dart';
import 'package:responsi/services/auth_service.dart';
import 'package:responsi/services/post_service.dart';
import 'package:responsi/services/notification_service.dart';
import 'package:responsi/services/story_service.dart';
import 'package:responsi/services/chat_service.dart';
import 'package:responsi/models/post_model.dart';
import 'package:responsi/models/story_model.dart';
import 'package:responsi/widgets/post_card.dart';
import 'package:responsi/widgets/message_notification_popup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_page.dart';
import 'story_view_page.dart';
import 'reels_page.dart';
import 'notifications_page.dart';
import 'comments_page.dart';
import 'create_post_page.dart';
import 'create_story_page.dart';
import 'chat_list_page.dart';
import 'profile_page.dart';
import 'pages_menu_page.dart';
import 'components_menu_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  final PostService _postService = PostService();
  final NotificationService _notificationService = NotificationService();
  final StoryService _storyService = StoryService();
  final ChatService _chatService = ChatService();

  int _selectedIndex = 0;
  bool _isDarkMode = false;
  Color _primaryColor = Colors.orange;

  List<PostModel> _posts = [];
  bool _isLoadingPosts = true;
  int _unreadNotificationCount = 0;
  
  Map<String, List<StoryModel>> _groupedStories = {};
  List<StoryModel> _myStories = [];
  bool _isLoadingStories = true;

  // Real-time subscription channels
  RealtimeChannel? _postsChannel;
  RealtimeChannel? _postsUpdatesChannel;
  RealtimeChannel? _postsDeletionsChannel;
  RealtimeChannel? _notificationsChannel;
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _storiesChannel;
  RealtimeChannel? _storiesDeletionsChannel;

  final List<Color> _themeColors = [
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.pink,
    Colors.teal,
  ];



  List<bool> liked = [false, false];
  List<int> likeCount = [221, 178];

  Color get _backgroundColor => _isDarkMode ? Color(0xFF1A1A1A) : Colors.white;
  Color get _cardColor => _isDarkMode ? Color(0xFF2A2A2A) : Colors.white;
  Color get _textColor => _isDarkMode ? Colors.white : Colors.black;
  Color get _subtitleColor => _isDarkMode ? Colors.grey[400]! : Colors.grey;
  Color get _appBarColor => _isDarkMode ? Color(0xFF2A2A2A) : Colors.white;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadUnreadCount();
    _loadStories();
    _setupRealtimeSubscriptions();
  }

  @override
  void dispose() {
    _cleanupSubscriptions();
    super.dispose();
  }

  void _setupRealtimeSubscriptions() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    // Subscribe to new posts
    _postsChannel = _postService.subscribeToNewPosts((newPostData) {
      if (mounted) {
        setState(() {
          // Add new post to the beginning of the list
          final newPost = PostModel.fromMap(newPostData);
          _posts.insert(0, newPost);
        });
        
        // Show notification snackbar for new post
        final username = newPostData['profiles']?['username'] ?? 'Someone';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📮 New post from $username'),
            duration: Duration(seconds: 2),
            backgroundColor: _primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // Subscribe to post updates (likes, comments)
    _postsUpdatesChannel = _postService.subscribeToPostUpdates((updatedPostData) {
      if (mounted) {
        setState(() {
          final index = _posts.indexWhere((post) => post.id == updatedPostData['id']);
          if (index != -1) {
            // Update the post with new data
            _posts[index] = PostModel.fromMap({
              ..._posts[index].toMap(),
              'like_count': updatedPostData['like_count'],
              'comment_count': updatedPostData['comment_count'],
            });
          }
        });
      }
    });

    // Subscribe to post deletions
    _postsDeletionsChannel = _postService.subscribeToPostDeletions((deletedPostId) {
      if (mounted) {
        setState(() {
          _posts.removeWhere((post) => post.id == deletedPostId);
        });
      }
    });

    // Subscribe to notifications
    _notificationsChannel = _notificationService.subscribeToNotifications(
      currentUser.id,
      (newNotification) {
        if (mounted) {
          setState(() {
            _unreadNotificationCount++;
          });
          
          // Show notification badge or snackbar
          final type = newNotification['type'] ?? 'notification';
          String message = '🔔 New notification';
          
          switch (type) {
            case 'follow':
              message = '👥 Someone started following you';
              break;
            case 'like':
              message = '❤️ Someone liked your post';
              break;
            case 'comment':
              message = '💬 New comment on your post';
              break;
            case 'message':
              message = '✉️ New message received';
              break;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: Duration(seconds: 3),
              backgroundColor: _primaryColor,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsPage()),
                  );
                },
              ),
            ),
          );
        }
      },
    );

    // Subscribe to incoming messages
    _messagesChannel = _chatService.subscribeToIncomingMessages(
      currentUser.id,
      (messageData) {
        if (mounted) {
          print('💬 New incoming message received!');
          print('Message data: $messageData');
          
          final sender = messageData['sender'] as Map<String, dynamic>?;
          final senderName = sender?['username'] ?? sender?['name'] ?? 'Someone';
          final content = messageData['content'] as String? ?? '';
          final messageType = messageData['message_type'] as String? ?? 'text';
          final avatarUrl = sender?['avatar_url'];
          
          String displayContent = content;
          
          // Customize message display based on type
          switch (messageType) {
            case 'post':
              displayContent = '📮 Shared a post with you';
              break;
            case 'story':
              displayContent = '📸 Replied to your story';
              break;
            case 'text':
            default:
              // Keep full message for popup
              displayContent = content;
              break;
          }
          
          // Show beautiful pop-up notification
          MessageNotificationPopup.show(
            context: context,
            senderName: senderName,
            message: displayContent,
            avatarUrl: avatarUrl,
            onTap: () {
              print('🔔 Notification tapped, navigating to chat');
              // Navigate to chat
              setState(() => _selectedIndex = 2);
            },
            duration: Duration(seconds: 6),
          );
          
          print('✅ Message notification popup shown');
        }
      },
    );

    // Subscribe to new stories
    _storiesChannel = _storyService.subscribeToNewStories((newStoryData) {
      if (mounted) {
        print('📸 New story received!');
        
        // Reload stories to show new one
        _loadStories();
        
        // Show notification snackbar
        final profile = newStoryData['profiles'] as Map<String, dynamic>?;
        final username = profile?['username'] ?? profile?['name'] ?? 'Someone';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📸 New story from $username'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.purple,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // Subscribe to story deletions
    _storiesDeletionsChannel = _storyService.subscribeToStoryDeletions((deletedStoryId) {
      if (mounted) {
        print('🗑️ Story deleted: $deletedStoryId');
        // Reload stories
        _loadStories();
      }
    });

    print('✅ Real-time subscriptions setup completed');
  }

  Future<void> _cleanupSubscriptions() async {
    if (_postsChannel != null) {
      await _postService.unsubscribeFromChannel(_postsChannel!);
    }
    if (_postsUpdatesChannel != null) {
      await _postService.unsubscribeFromChannel(_postsUpdatesChannel!);
    }
    if (_postsDeletionsChannel != null) {
      await _postService.unsubscribeFromChannel(_postsDeletionsChannel!);
    }
    if (_notificationsChannel != null) {
      await _notificationService.unsubscribeFromNotifications(_notificationsChannel!);
    }
    if (_messagesChannel != null) {
      await _chatService.unsubscribeFromChannel(_messagesChannel!);
    }
    if (_storiesChannel != null) {
      await _storyService.unsubscribeFromChannel(_storiesChannel!);
    }
    if (_storiesDeletionsChannel != null) {
      await _storyService.unsubscribeFromChannel(_storiesDeletionsChannel!);
    }
    print('✅ Real-time subscriptions cleaned up');
  }

  Future<void> _loadStories() async {
    setState(() => _isLoadingStories = true);
    try {
      final allStories = await _storyService.getActiveStories();
      final myStories = await _storyService.getMyStories();
      
      if (mounted) {
        setState(() {
          _groupedStories = _storyService.groupStoriesByUser(allStories);
          _myStories = myStories;
          _isLoadingStories = false;
        });
      }
    } catch (e) {
      print('Error loading stories: $e');
      if (mounted) {
        setState(() => _isLoadingStories = false);
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadNotificationCount = count;
      });
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final posts = await _postService.getPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPosts = false);
      }
    }
  }

  void _showColorThemePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Choose Color Theme',
            style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _themeColors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _primaryColor = _themeColors[index];
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Theme color changed!'),
                        backgroundColor: _primaryColor,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _themeColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primaryColor == _themeColors[index]
                            ? _textColor
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: _primaryColor == _themeColors[index]
                        ? Icon(Icons.check, color: Colors.white, size: 30)
                        : null,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Method untuk memilih halaman berdasarkan selectedIndex
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return SearchPage();
      case 2:
        return ChatListPage();
      case 3:
        return ProfilePage();
      default:
        return _buildHomePage();
    }
  }

  // Method untuk handle logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _authService.signOut();
                // Navigate to Sign In and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8A5B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      body: _getSelectedPage(),
      endDrawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostPage()),
          );
          // Refresh posts jika berhasil membuat post baru
          if (result == true) {
            _loadPosts();
          }
        },
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        color: _appBarColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 0 ? _primaryColor : _subtitleColor,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: _selectedIndex == 1 ? _primaryColor : _subtitleColor,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: _selectedIndex == 2 ? _primaryColor : _subtitleColor,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.person_outline,
                  color: _selectedIndex == 3 ? _primaryColor : _subtitleColor,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Home",
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: _appBarColor,
          elevation: 0,
          floating: true,
          pinned: false,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none, color: _primaryColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationsPage()),
                    ).then((_) => _loadUnreadCount());
                  },
                ),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.video_collection_outlined, color: _primaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReelsPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.grid_view, color: _primaryColor),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
            SizedBox(width: 10),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildStoriesSection(),
              
              // Supabase Posts Section
              if (_isLoadingPosts)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(color: _primaryColor),
                  ),
                )
              else if (_posts.isNotEmpty)
                ..._posts
                    .map(
                      (post) => PostCard(
                        post: post,
                        // onLike di-handle internal di PostCard, tidak perlu reload
                        onComment: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentsPage(
                                postId: post.id,
                                postOwnerId: post.userId,
                              ),
                            ),
                          );
                          // Reload posts after returning from comments
                          _loadPosts();
                        },
                        onShare: () => _showShareBottomSheet(context),
                        onDelete: () {
                          print('🔄 Removing post from UI: ${post.id}');
                          // Langsung remove dari list tanpa reload
                          setState(() {
                            _posts.removeWhere((p) => p.id == post.id);
                            print('✅ Posts remaining: ${_posts.length}');
                          });
                        },
                      ),
                    )
                    .toList()
              else
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No posts from database yet',
                    style: TextStyle(color: _subtitleColor),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoriesSection() {
    // Always show stories section (at least show "Add Story" button)
    List<Widget> storyWidgets = [];
    
    // ALWAYS add "Your Story" button first
    storyWidgets.add(_buildMyStoryWidget());
    
    // Add other users' stories if not loading
    if (!_isLoadingStories) {
      _groupedStories.forEach((userId, userStories) {
        if (userId != _authService.currentUser?.id && userStories.isNotEmpty) {
          storyWidgets.add(_buildStoryWidget(userStories));
        }
      });
    }

    return Container(
      height: 110,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: _isLoadingStories
          ? Center(
              child: CircularProgressIndicator(color: _primaryColor),
            )
          : ListView(
              scrollDirection: Axis.horizontal,
              children: storyWidgets,
            ),
    );
  }

  Widget _buildMyStoryWidget() {
    return GestureDetector(
      onTap: () async {
        // Always show option to create new story or view existing
        if (_myStories.isEmpty) {
          // If no stories, directly go to create
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateStoryPage()),
          );
          if (result == true) {
            _loadStories();
          }
        } else {
          // If has stories, show options
          _showMyStoryOptions();
        }
      },
      child: Container(
        width: 75,
        margin: EdgeInsets.only(left: 12, right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer container with gradient border if has stories
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _myStories.isNotEmpty
                        ? LinearGradient(
                            colors: [Colors.grey, Colors.grey.shade400],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          )
                        : null,
                    border: _myStories.isEmpty 
                        ? Border.all(color: Colors.grey.shade300, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _backgroundColor,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _authService.currentUser?.userMetadata?['avatar_url'] != null
                            ? NetworkImage(_authService.currentUser!.userMetadata!['avatar_url'])
                            : null,
                        child: _authService.currentUser?.userMetadata?['avatar_url'] == null
                            ? Icon(Icons.person, color: Colors.grey, size: 28)
                            : null,
                      ),
                    ),
                  ),
                ),
                // Add button - ALWAYS show
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: _backgroundColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Cerita Anda',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showMyStoryOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.visibility, color: _primaryColor),
                title: Text('Lihat Cerita Saya'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryViewPage(
                        stories: _myStories,
                        initialIndex: 0,
                      ),
                    ),
                  );
                  if (result == true) {
                    _loadStories();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.add_photo_alternate, color: _primaryColor),
                title: Text('Tambah Cerita Baru'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateStoryPage()),
                  );
                  if (result == true) {
                    _loadStories();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.grey),
                title: Text('Batal'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoryWidget(List<StoryModel> userStories) {
    final story = userStories.first;
    final hasMultipleStories = userStories.length > 1;
    final hasUnviewed = _storyService.hasUnviewedStories(userStories);
    
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryViewPage(
              stories: userStories,
              initialIndex: 0,
            ),
          ),
        );
        if (result == true) {
          _loadStories(); // Reload stories after viewing
        }
      },
      child: Container(
        width: 70,
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Gradient border - RED if unviewed, GREY if all viewed
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: hasUnviewed
                          ? [Color(0xFFFF0000), Color(0xFFFF6B6B)] // Red gradient
                          : [Colors.grey, Colors.grey.shade400], // Grey gradient
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _backgroundColor,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: story.avatarUrl != null
                            ? NetworkImage(story.avatarUrl!)
                            : null,
                        child: story.avatarUrl == null
                            ? Icon(Icons.person, color: Colors.white, size: 26)
                            : null,
                      ),
                    ),
                  ),
                ),
                if (hasMultipleStories)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: hasUnviewed ? Colors.red : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: _backgroundColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${userStories.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              story.username ?? 'User',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard({
    required int index,
    required String userName,
    required String location,
    required String timeAgo,
    required String text,
    required String imageUrl,
    required int likes,
    required String comments,
  }) {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: _isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/9.jpg',
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: _subtitleColor),
                      Text(
                        '$location • $timeAgo',
                        style: TextStyle(color: _subtitleColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  _showShareBottomSheet(context);
                },
                child: Icon(Icons.share, color: _primaryColor),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(text, style: TextStyle(fontSize: 13, color: _textColor)),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    liked[index] = !liked[index];
                    liked[index] ? likeCount[index]++ : likeCount[index]--;
                  });
                },
                child: Icon(
                  liked[index] ? Icons.favorite : Icons.favorite_border,
                  color: liked[index] ? Colors.red : _subtitleColor,
                ),
              ),
              SizedBox(width: 5),
              Text(
                likeCount[index].toString(),
                style: TextStyle(color: _textColor),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  // Ini untuk old static post, skip comment feature
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comment feature only for real posts from database'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.purple),
                    SizedBox(width: 5),
                    Text(comments, style: TextStyle(color: _textColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 280,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(25)),
      ),
      child: Container(
        color: Color(0xFFFFA36C),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(color: Color(0xFFFFA36C)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/women/2.jpg',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Good Morning", style: TextStyle(color: Colors.white70)),
                  Text(
                    "Emilia",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MAIN MENU",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  _drawerItem(
                    Icons.favorite,
                    "Welcome",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomePage()),
                      );
                    },
                  ),
                  _drawerItem(
                    Icons.home,
                    "Home",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  _drawerItem(
                    Icons.layers,
                    "Pages",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PagesMenuPage(
                            onNavigateToIndex: (index) {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                    Icons.widgets_outlined,
                    "Components",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComponentsMenuPage(),
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                    Icons.notifications,
                    "Notification",
                    badge: 1,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                    Icons.person_outline,
                    "Profile",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                  _drawerItem(
                    Icons.chat,
                    "Chat",
                    badge: 5,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                  _drawerItem(
                    Icons.logout,
                    "Logout",
                    onTap: () {
                      Navigator.pop(context);
                      _handleLogout();
                    },
                  ),
                  Divider(color: Colors.white70),
                  SizedBox(height: 10),
                  Text(
                    "SETTINGS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  _drawerItem(
                    Icons.color_lens_outlined,
                    "Color Theme",
                    onTap: () {
                      Navigator.pop(context);
                      _showColorThemePicker();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.nightlight_round, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "Dark Mode",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              _isDarkMode = value;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Dark Mode ${value ? "enabled" : "disabled"}',
                                ),
                                backgroundColor: _primaryColor,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          activeColor: _primaryColor,
                        ),
                      ],
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

  Widget _drawerItem(
    IconData icon,
    String title, {
    int? badge,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: badge != null
          ? Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badge',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    final List<Map<String, String>> users = [
      {
        'name': 'Andy Lee',
        'username': 'mr_andy_lee',
        'image': 'https://randomuser.me/api/portraits/women/10.jpg',
      },
      {
        'name': 'Brian Harahap',
        'username': 'brian_harahap',
        'image': 'https://randomuser.me/api/portraits/men/11.jpg',
      },
      {
        'name': 'Christian Hang',
        'username': 'christian_Hang',
        'image': 'https://randomuser.me/api/portraits/men/12.jpg',
      },
      {
        'name': 'Chloe Mc. Jenskin',
        'username': 'chloe_mc_jenskin',
        'image': 'https://randomuser.me/api/portraits/women/13.jpg',
      },
      {
        'name': 'David Bekam',
        'username': 'david_bekam',
        'image': 'https://randomuser.me/api/portraits/men/14.jpg',
      },
      {
        'name': 'Donas High',
        'username': 'donas_high',
        'image': 'https://randomuser.me/api/portraits/men/15.jpg',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Write a message ...',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search..',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              users[index]['image']!,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  users[index]['name']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  users[index]['username']!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Shared to ${users[index]['name']}',
                                  ),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Send',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
