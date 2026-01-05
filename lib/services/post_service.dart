import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'supabase_service.dart';
import '../models/post_model.dart';

class PostService {
  final SupabaseClient _client = SupabaseService.client;
  final Uuid _uuid = Uuid();

  // Upload image ke Supabase Storage
  Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ ERROR: User not logged in');
        return null;
      }

      print('✅ User logged in: ${user.id}');
      print('📁 Uploading to bucket: posts');
      print('📄 File name: $fileName');
      print('📊 File size: ${imageBytes.length} bytes');

      final fileExt = fileName.split('.').last;
      final uniqueFileName = '${_uuid.v4()}.$fileExt';
      final filePath = '${user.id}/$uniqueFileName';

      print('📂 File path: $filePath');

      await _client.storage
          .from('posts')
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      print('✅ Upload successful!');

      final imageUrl = _client.storage.from('posts').getPublicUrl(filePath);
      print('🔗 Image URL: $imageUrl');

      return imageUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Full error: ${e.toString()}');
      return null;
    }
  }

  // Upload image dari file path (untuk mobile)
  Future<String?> uploadImageFromFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;
      return uploadImage(imageBytes: bytes, fileName: fileName);
    } catch (e) {
      print('Error uploading image from file: $e');
      return null;
    }
  }

  // Create new post
  Future<PostModel?> createPost({
    required String content,
    String? imageUrl,
    String privacy = 'public',
    String? location,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ ERROR: User not logged in (createPost)');
        return null;
      }

      print('📝 Creating post...');
      print('👤 User ID: ${user.id}');
      print('📄 Content: $content');
      print('🖼️ Image URL: ${imageUrl ?? "No image"}');
      print('🔒 Privacy: $privacy');

      // Get user profile
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      print('✅ Profile fetched: ${profile['name']}');

      final postData = {
        'user_id': user.id,
        'content': content,
        'image_url': imageUrl,
        'privacy': privacy,
        'location': location,
        'likes_count': 0,
        'comments_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('💾 Inserting post to database...');
      final response = await _client
          .from('posts')
          .insert(postData)
          .select()
          .single();

      print('✅ Post created successfully!');
      print('🆔 Post ID: ${response['id']}');

      return PostModel.fromJson(response, profile);
    } catch (e) {
      print('❌ Error creating post: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Full error: ${e.toString()}');
      return null;
    }
  }

  // Get all posts (feed)
  Future<List<PostModel>> getPosts({int limit = 20, int offset = 0}) async {
    try {
      print('📥 Fetching posts from database...');
      print('📊 Limit: $limit, Offset: $offset');

      final response = await _client
          .from('posts')
          .select('*, profiles(*)')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      print('✅ Database response: ${(response as List).length} posts');

      final posts = (response as List).map((post) {
        final profile = post['profiles'];
        return PostModel.fromJson(post, profile);
      }).toList();

      print('✅ Posts parsed successfully: ${posts.length} posts');
      if (posts.isNotEmpty) {
        print('📝 First post: ${posts[0].content}');
        print('🖼️ First post image: ${posts[0].imageUrl ?? "No image"}');
      }

      return posts;
    } catch (e) {
      print('❌ Error getting posts: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Full error: ${e.toString()}');
      return [];
    }
  }

  // Get posts by user
  Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final response = await _client
          .from('posts')
          .select('*, profiles(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((post) {
        final profile = post['profiles'];
        return PostModel.fromJson(post, profile);
      }).toList();
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }

  // Like a post
  Future<bool> likePost(String postId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Check if already liked
      final existing = await _client
          .from('likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) {
        // Unlike
        await _client
            .from('likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);

        await _client.rpc('decrement_likes', params: {'post_id': postId});
        return false;
      } else {
        // Like
        await _client.from('likes').insert({
          'post_id': postId,
          'user_id': user.id,
          'created_at': DateTime.now().toIso8601String(),
        });

        await _client.rpc('increment_likes', params: {'post_id': postId});
        return true;
      }
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  // Check if post is liked by current user
  Future<bool> isPostLiked(String postId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response = await _client
          .from('likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Add comment to post
  Future<bool> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      print('💬 Adding comment to post: $postId');
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return false;
      }

      final commentData = {
        'post_id': postId,
        'user_id': user.id,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      };

      if (parentCommentId != null) {
        commentData['parent_comment_id'] = parentCommentId;
        print('↩️ This is a reply to: $parentCommentId');
      }

      await _client.from('comments').insert(commentData);
      print('✅ Comment inserted to database');

      // Increment comment count
      try {
        await _client.rpc('increment_comments', params: {'post_id': postId});
        print('✅ Comment count incremented');
      } catch (rpcError) {
        print('⚠️ Error incrementing comment count: $rpcError');
        // Continue even if increment fails
      }

      return true;
    } catch (e) {
      print('❌ Error adding comment: $e');
      return false;
    }
  }

  // Get comments for a post
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await _client
          .from('comments')
          .select('*, profiles(*)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  // Delete comment
  Future<bool> deleteComment(String commentId, String postId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', user.id);

      await _client.rpc('decrement_comments', params: {'post_id': postId});
      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  // Delete post
  Future<bool> deletePost(String postId) async {
    try {
      print('🗑️ Starting delete post: $postId');
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return false;
      }

      // First, get the post to retrieve image_url for storage deletion
      final postData = await _client
          .from('posts')
          .select('image_url')
          .eq('id', postId)
          .eq('user_id', user.id)
          .maybeSingle();

      // Check if post exists and belongs to user
      if (postData == null) {
        print('⚠️ Post not found or does not belong to current user');
        return false;
      }

      print('✅ Post data retrieved: $postData');

      // Delete from database first
      await _client
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', user.id);

      print('✅ Post deleted from database');

      // Extract filename from image_url and delete from storage
      if (postData['image_url'] != null) {
        final imageUrl = postData['image_url'] as String;
        // Extract filename from URL (format: .../posts/filename.ext)
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final filename = pathSegments.last;
          print('📁 Attempting to delete file from storage: $filename');
          
          try {
            await _client.storage.from('posts').remove([filename]);
            print('✅ File deleted from storage: $filename');
          } catch (storageError) {
            print('⚠️ Could not delete file from storage: $storageError');
            // Continue even if storage deletion fails
          }
        }
      }

      print('✅ Delete post completed successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting post: $e');
      return false;
    }
  }

  // Listen to real-time post changes (inserts)
  RealtimeChannel subscribeToNewPosts(
    void Function(Map<String, dynamic>) onNewPost,
  ) {
    final channel = _client
        .channel('posts:public')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'posts',
          callback: (payload) async {
            print('📮 New post detected: ${payload.newRecord['id']}');
            
            // Fetch complete post data with profile information
            try {
              final postData = await _client
                  .from('posts')
                  .select('''
                    *,
                    profiles:user_id (
                      id,
                      username,
                      name,
                      avatar_url
                    )
                  ''')
                  .eq('id', payload.newRecord['id'])
                  .single();
              
              onNewPost(postData);
            } catch (e) {
              print('❌ Error fetching new post details: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }

  // Listen to real-time post updates (likes, comments count)
  RealtimeChannel subscribeToPostUpdates(
    void Function(Map<String, dynamic>) onPostUpdate,
  ) {
    final channel = _client
        .channel('posts:updates')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            print('📝 Post updated: ${payload.newRecord['id']}');
            onPostUpdate(payload.newRecord);
          },
        )
        .subscribe();

    return channel;
  }

  // Listen to real-time post deletions
  RealtimeChannel subscribeToPostDeletions(
    void Function(String postId) onPostDelete,
  ) {
    final channel = _client
        .channel('posts:deletions')
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            print('🗑️ Post deleted: ${payload.oldRecord['id']}');
            onPostDelete(payload.oldRecord['id']);
          },
        )
        .subscribe();

    return channel;
  }

  // Unsubscribe from channel
  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
