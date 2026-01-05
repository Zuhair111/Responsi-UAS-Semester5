import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get or create conversation between two users
  Future<String?> getOrCreateConversation(String otherUserId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return null;
      }

      print('💬 Getting/creating conversation between $currentUserId and $otherUserId');

      // Call the database function to get or create conversation
      final response = await _supabase.rpc(
        'get_or_create_conversation',
        params: {
          'p_user1_id': currentUserId,
          'p_user2_id': otherUserId,
        },
      );

      print('✅ Conversation ID: $response');
      return response.toString();
    } catch (e) {
      print('❌ Error getting/creating conversation: $e');
      return null;
    }
  }

  // Send a message
  Future<bool> sendMessage(String conversationId, String receiverId, String content) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return false;
      }

      print('💬 Sending message to conversation: $conversationId');

      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'content': content,
        'message_type': 'text',
      });

      print('✅ Message sent successfully');
      return true;
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }

  // Send a post as message
  Future<bool> sendPostMessage(String conversationId, String receiverId, String postId, String postContent) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return false;
      }

      print('💬 Sending post to conversation: $conversationId');

      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'content': postContent,
        'message_type': 'post',
        'post_id': postId,
      });

      print('✅ Post sent successfully');
      return true;
    } catch (e) {
      print('❌ Error sending post: $e');
      return false;
    }
  }

  // Send a story reply as message
  Future<bool> sendStoryMessage(String conversationId, String receiverId, String storyId, String storyImageUrl, String message) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return false;
      }

      print('💬 Sending story reply to conversation: $conversationId');

      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'content': message,
        'message_type': 'story',
        'story_id': storyId,
        'story_image_url': storyImageUrl,
      });

      print('✅ Story reply sent successfully');
      return true;
    } catch (e) {
      print('❌ Error sending story reply: $e');
      return false;
    }
  }

  // Get messages for a conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      print('💬 Getting messages for conversation: $conversationId');

      final response = await _supabase
          .from('messages')
          .select('''
            *,
            sender:sender_id(id, username, avatar_url),
            receiver:receiver_id(id, username, avatar_url),
            post:post_id(id, content, image_url, user_id)
          ''')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      print('✅ Fetched ${response.length} messages');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting messages: $e');
      return [];
    }
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(String conversationId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      print('💬 Marking messages as read for conversation: $conversationId');

      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .eq('receiver_id', currentUserId)
          .eq('is_read', false);

      print('✅ Messages marked as read');
      return true;
    } catch (e) {
      print('❌ Error marking messages as read: $e');
      return false;
    }
  }

  // Get all conversations for current user
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return [];
      }

      print('💬 Getting conversations for user: $currentUserId');

      final response = await _supabase
          .from('conversations')
          .select('''
            *,
            user1:user1_id(id, username, avatar_url),
            user2:user2_id(id, username, avatar_url)
          ''')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
          .order('last_message_at', ascending: false);

      print('✅ Fetched ${response.length} conversations');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting conversations: $e');
      return [];
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return 0;

      final response = await _supabase.rpc(
        'get_unread_message_count',
        params: {'p_user_id': currentUserId},
      );

      return response as int;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  // Subscribe to new messages in a conversation
  RealtimeChannel subscribeToMessages(String conversationId, Function(Map<String, dynamic>) onNewMessage) {
    print('💬 Subscribing to messages for conversation: $conversationId');

    return _supabase
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            print('💬 New message received: ${payload.newRecord}');
            onNewMessage(payload.newRecord);
          },
        )
        .subscribe();
  }

  // Subscribe to all incoming messages for current user
  RealtimeChannel subscribeToIncomingMessages(
    String userId,
    Function(Map<String, dynamic>) onNewMessage,
  ) {
    print('💬 Subscribing to all incoming messages for user: $userId');

    return _supabase
        .channel('messages:incoming:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) async {
            print('💬 New incoming message: ${payload.newRecord}');
            
            // Fetch sender profile information
            try {
              final senderId = payload.newRecord['sender_id'];
              final profile = await _supabase
                  .from('profiles')
                  .select('id, username, name, avatar_url')
                  .eq('id', senderId)
                  .single();
              
              final enrichedMessage = {
                ...payload.newRecord,
                'sender': profile,
              };
              
              onNewMessage(enrichedMessage);
            } catch (e) {
              print('❌ Error fetching sender profile: $e');
              onNewMessage(payload.newRecord);
            }
          },
        )
        .subscribe();
  }

  // Unsubscribe from channel
  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }

  // Delete a message (sender only)
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
      print('✅ Message deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting message: $e');
      return false;
    }
  }
}
