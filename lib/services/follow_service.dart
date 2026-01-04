import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class FollowService {
  final SupabaseClient _client = SupabaseService.client;

  // Follow a user
  Future<bool> followUser(String followingId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return false;
      }

      print('👥 Following user: $followingId');

      await _client.from('follows').insert({
        'follower_id': user.id,
        'following_id': followingId,
      });

      print('✅ Successfully followed user');
      return true;
    } catch (e) {
      print('❌ Error following user: $e');
      return false;
    }
  }

  // Unfollow a user
  Future<bool> unfollowUser(String followingId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return false;
      }

      print('👥 Unfollowing user: $followingId');

      await _client
          .from('follows')
          .delete()
          .eq('follower_id', user.id)
          .eq('following_id', followingId);

      print('✅ Successfully unfollowed user');
      return true;
    } catch (e) {
      print('❌ Error unfollowing user: $e');
      return false;
    }
  }

  // Check if current user is following another user
  Future<bool> isFollowing(String userId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return false;
      }

      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_id', user.id)
          .eq('following_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error checking follow status: $e');
      return false;
    }
  }

  // Get follower count for a user
  Future<int> getFollowerCount(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('following_id', userId);

      return response.length;
    } catch (e) {
      print('❌ Error getting follower count: $e');
      return 0;
    }
  }

  // Get following count for a user
  Future<int> getFollowingCount(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_id', userId);

      return response.length;
    } catch (e) {
      print('❌ Error getting following count: $e');
      return 0;
    }
  }

  // Get list of followers for a user
  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('follower_id, profiles!follows_follower_id_fkey(*)')
          .eq('following_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting followers: $e');
      return [];
    }
  }

  // Get list of users that a user is following
  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      print('📋 Getting following for user: $userId');
      final response = await _client
          .from('follows')
          .select('following_id, profiles!follows_following_id_fkey(*)')
          .eq('follower_id', userId)
          .order('created_at', ascending: false);

      print('📋 Following response: $response');
      print('📋 Following count: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting following: $e');
      return [];
    }
  }
}
