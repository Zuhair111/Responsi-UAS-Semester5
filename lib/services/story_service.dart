import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:responsi/models/story_model.dart';

class StoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload story image to Supabase Storage (for mobile)
  Future<String?> uploadStoryImage(File imageFile) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'stories/$currentUserId/$timestamp.jpg';

      print('📸 Uploading story image: $fileName');

      await _supabase.storage.from('avatars').upload(
        fileName,
        imageFile,
        fileOptions: FileOptions(
          upsert: false,
        ),
      );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      
      print('✅ Story image uploaded: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading story image: $e');
      return null;
    }
  }

  // Upload story image to Supabase Storage (for web)
  Future<String?> uploadStoryImageWeb(XFile imageFile) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'stories/$currentUserId/$timestamp.jpg';

      print('📸 Uploading story image (web): $fileName');

      final bytes = await imageFile.readAsBytes();
      
      await _supabase.storage.from('avatars').uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(
          upsert: false,
        ),
      );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      
      print('✅ Story image uploaded (web): $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading story image (web): $e');
      return null;
    }
  }

  // Create a new story
  Future<bool> createStory(String imageUrl) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return false;
      }

      final now = DateTime.now();
      final expiresAt = now.add(Duration(hours: 24)); // Story expires in 24 hours

      print('📝 Creating story for user: $currentUserId');

      await _supabase.from('stories').insert({
        'user_id': currentUserId,
        'image_url': imageUrl,
        'created_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      });

      print('✅ Story created successfully');
      return true;
    } catch (e) {
      print('❌ Error creating story: $e');
      return false;
    }
  }

  // Get all active stories (not expired) with viewed status
  Future<List<StoryModel>> getActiveStories() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return [];
      }

      print('📖 Fetching active stories');

      final now = DateTime.now().toIso8601String();
      
      // Fetch stories without embedded user
      final response = await _supabase
          .from('stories')
          .select('*')
          .gt('expires_at', now)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        print('✅ No active stories found');
        return [];
      }

      // Get unique user IDs
      final userIds = (response as List)
          .map((s) => s['user_id'] as String)
          .toSet()
          .toList();

      // Fetch user data
      final usersResponse = await _supabase
          .from('profiles')
          .select('id, username, avatar_url')
          .inFilter('id', userIds);

      final usersMap = {for (var u in usersResponse) u['id']: u};

      // Get all viewed story IDs for current user
      final viewedResponse = await _supabase
          .from('story_views')
          .select('story_id')
          .eq('viewer_id', currentUserId);
      
      final viewedStoryIds = (viewedResponse as List)
          .map((v) => v['story_id'] as String)
          .toSet();

      print('✅ Fetched ${response.length} active stories, ${viewedStoryIds.length} viewed');
      
      return (response as List).map((json) {
        json['is_viewed'] = viewedStoryIds.contains(json['id']);
        // Add user data
        final userId = json['user_id'] as String;
        if (usersMap.containsKey(userId)) {
          json['user'] = usersMap[userId];
        }
        return StoryModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('❌ Error fetching stories: $e');
      return [];
    }
  }

  // Get stories for a specific user
  Future<List<StoryModel>> getUserStories(String userId) async {
    try {
      print('📖 Fetching stories for user: $userId');

      final now = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from('stories')
          .select('*')
          .eq('user_id', userId)
          .gt('expires_at', now)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        print('✅ No stories found for user');
        return [];
      }

      // Fetch user data
      final userResponse = await _supabase
          .from('profiles')
          .select('id, username, avatar_url')
          .eq('id', userId)
          .single();

      print('✅ Fetched ${response.length} stories for user');
      
      return (response as List).map((json) {
        json['user'] = userResponse;
        return StoryModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('❌ Error fetching user stories: $e');
      return [];
    }
  }

  // Get current user's stories
  Future<List<StoryModel>> getMyStories() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return [];
      }

      return await getUserStories(currentUserId);
    } catch (e) {
      print('❌ Error fetching my stories: $e');
      return [];
    }
  }

  // Delete a story
  Future<bool> deleteStory(String storyId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return false;
      }

      print('🗑️ Deleting story: $storyId');

      await _supabase
          .from('stories')
          .delete()
          .eq('id', storyId)
          .eq('user_id', currentUserId);

      print('✅ Story deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting story: $e');
      return false;
    }
  }

  // Group stories by user
  Map<String, List<StoryModel>> groupStoriesByUser(List<StoryModel> stories) {
    final Map<String, List<StoryModel>> grouped = {};
    
    for (var story in stories) {
      if (!grouped.containsKey(story.userId)) {
        grouped[story.userId] = [];
      }
      grouped[story.userId]!.add(story);
    }
    
    return grouped;
  }

  // Mark story as viewed
  Future<bool> markStoryAsViewed(String storyId) async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        print('❌ No authenticated user');
        return false;
      }

      print('👁️ Marking story as viewed: $storyId');

      await _supabase.from('story_views').upsert(
        {
          'story_id': storyId,
          'viewer_id': currentUserId,
          'viewed_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'story_id,viewer_id',
      );

      print('✅ Story marked as viewed');
      return true;
    } catch (e) {
      print('❌ Error marking story as viewed: $e');
      return false;
    }
  }

  // Check if user has any unviewed stories
  bool hasUnviewedStories(List<StoryModel> stories) {
    return stories.any((story) => !story.isViewed);
  }

  // Listen to real-time new stories
  RealtimeChannel subscribeToNewStories(
    void Function(Map<String, dynamic>) onNewStory,
  ) {
    final channel = _supabase
        .channel('stories:public')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'stories',
          callback: (payload) async {
            print('📸 New story detected: ${payload.newRecord['id']}');
            
            // Fetch complete story data with profile information
            try {
              final userId = payload.newRecord['user_id'];
              
              // Fetch story
              final storyData = await _supabase
                  .from('stories')
                  .select('*')
                  .eq('id', payload.newRecord['id'])
                  .single();
              
              // Fetch profile separately
              final profile = await _supabase
                  .from('profiles')
                  .select('id, username, name, avatar_url')
                  .eq('id', userId)
                  .single();
              
              // Combine data
              storyData['profiles'] = profile;
              
              onNewStory(storyData);
            } catch (e) {
              print('❌ Error fetching new story details: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }

  // Listen to real-time story deletions
  RealtimeChannel subscribeToStoryDeletions(
    void Function(String storyId) onStoryDelete,
  ) {
    final channel = _supabase
        .channel('stories:deletions')
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'stories',
          callback: (payload) {
            print('🗑️ Story deleted: ${payload.oldRecord['id']}');
            onStoryDelete(payload.oldRecord['id']);
          },
        )
        .subscribe();

    return channel;
  }

  // Unsubscribe from channel
  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }
}
