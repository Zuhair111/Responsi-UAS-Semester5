import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class NotificationService {
  final SupabaseClient _client = SupabaseService.client;

  // Get notifications for current user
  Future<List<Map<String, dynamic>>> getNotifications({int limit = 50}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return [];
      }

      print('🔔 Fetching notifications for user: ${user.id}');

      final response = await _client
          .from('notifications')
          .select('''
            id,
            type,
            post_id,
            comment_id,
            message_id,
            is_read,
            created_at,
            actor:actor_id (
              id,
              username,
              name,
              avatar_url
            ),
            post:post_id (
              id,
              image_url,
              content
            ),
            comment:comment_id (
              id,
              content
            ),
            message:message_id (
              id,
              content,
              conversation_id
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      print('✅ Fetched ${response.length} notifications');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return [];
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;

      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      print('✅ Marked notification as read');
      return true;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);

      print('✅ Marked all notifications as read');
      return true;
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      print('✅ Deleted notification');
      return true;
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  // Delete all notifications
  Future<bool> deleteAllNotifications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('notifications')
          .delete()
          .eq('user_id', user.id);

      print('✅ Deleted all notifications');
      return true;
    } catch (e) {
      print('❌ Error deleting all notifications: $e');
      return false;
    }
  }

  // Listen to real-time notifications
  RealtimeChannel subscribeToNotifications(
    String userId,
    void Function(Map<String, dynamic>) onNotification,
  ) {
    final channel = _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            print('🔔 New notification received: ${payload.newRecord}');
            onNotification(payload.newRecord);
          },
        )
        .subscribe();

    return channel;
  }

  // Unsubscribe from notifications
  Future<void> unsubscribeFromNotifications(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
