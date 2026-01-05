import 'package:flutter/material.dart';
import 'package:responsi/services/notification_service.dart';
import 'package:responsi/services/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_profile_page.dart';
import 'comments_page.dart';
import 'chat_page.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  RealtimeChannel? _notificationsChannel;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _cleanupSubscription();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    _notificationsChannel = _notificationService.subscribeToNotifications(
      currentUser.id,
      (newNotification) async {
        if (mounted) {
          // Fetch full notification data with relationships
          final notifications = await _notificationService.getNotifications(limit: 1);
          if (notifications.isNotEmpty) {
            setState(() {
              // Add to the beginning of the list
              _notifications.insert(0, notifications.first);
            });

            // Show a subtle notification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🔔 New notification received'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );

    print('✅ Real-time notifications subscription setup');
  }

  Future<void> _cleanupSubscription() async {
    if (_notificationsChannel != null) {
      await _notificationService.unsubscribeFromNotifications(_notificationsChannel!);
      print('✅ Real-time notifications subscription cleaned up');
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getNotificationText(Map<String, dynamic> notification) {
    final type = notification['type'];
    final actor = notification['actor'] as Map<String, dynamic>?;
    final actorName = actor?['username'] ?? actor?['name'] ?? 'Someone';

    switch (type) {
      case 'follow':
        return '$actorName started following you';
      case 'comment':
        final comment = notification['comment'] as Map<String, dynamic>?;
        final commentText = comment?['content'] ?? '';
        return '$actorName commented: ${commentText.length > 50 ? commentText.substring(0, 50) + '...' : commentText}';
      case 'like':
        return '$actorName liked your post';
      case 'message':
        final message = notification['message'] as Map<String, dynamic>?;
        final messageText = message?['content'] ?? '';
        return '$actorName sent you a message: ${messageText.length > 50 ? messageText.substring(0, 50) + '...' : messageText}';
      default:
        return 'New notification';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'follow':
        return Icons.person_add;
      case 'message':
        return Icons.message;
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'like':
        return Icons.favorite;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'follow':
        return Colors.blue;
      case 'comment':
        return Colors.purple;
      case 'message':
        return Colors.green;
      case 'like':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) async {
    // Mark as read
    await _notificationService.markAsRead(notification['id']);
    
    final type = notification['type'];
    final actor = notification['actor'] as Map<String, dynamic>?;

    if (type == 'follow' && actor != null) {
      // Navigate to user profile
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(
            userId: actor['id'],
            username: actor['username'] ?? actor['name'],
          ),
        ),
      ).then((_) => _loadNotifications());
    } else if (type == 'comment' && notification['post_id'] != null) {
      // Navigate to post comments
      final postId = notification['post_id'];
      final currentUserId = _authService.currentUser?.id;
      if (currentUserId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentsPage(
              postId: postId,
              postOwnerId: currentUserId,
            ),
          ),
        ).then((_) => _loadNotifications());
      }
    } else if (type == 'message' && actor != null) {
      // Navigate to chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            otherUserId: actor['id'],
            otherUsername: actor['username'] ?? actor['name'],
            otherUserAvatar: actor['avatar_url'],
          ),
        ),
      ).then((_) => _loadNotifications());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_notifications.any((n) => n['is_read'] == false))
            TextButton(
              onPressed: () async {
                await _notificationService.markAllAsRead();
                _loadNotifications();
              },
              child: Text('Mark all read', style: TextStyle(color: Colors.orange)),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final actor = notification['actor'] as Map<String, dynamic>?;
                      final isRead = notification['is_read'] == true;
                      final createdAt = DateTime.parse(notification['created_at']);
                      
                      return Dismissible(
                        key: Key(notification['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _notificationService.deleteNotification(notification['id']);
                          setState(() {
                            _notifications.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Notification deleted')),
                          );
                        },
                        child: Container(
                          color: isRead ? Colors.transparent : Colors.orange.withOpacity(0.1),
                          child: ListTile(
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage: actor?['avatar_url'] != null
                                      ? NetworkImage(actor!['avatar_url'])
                                      : null,
                                  child: actor?['avatar_url'] == null
                                      ? Icon(Icons.person, color: Colors.grey)
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: _getNotificationColor(notification['type']),
                                    child: Icon(
                                      _getNotificationIcon(notification['type']),
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              _getNotificationText(notification),
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              timeago.format(createdAt),
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            onTap: () => _handleNotificationTap(notification),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}