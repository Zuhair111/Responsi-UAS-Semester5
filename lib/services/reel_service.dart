import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_compress/video_compress.dart';
import '../models/reel_model.dart';

class ReelService {
  final _supabase = Supabase.instance.client;

  // Upload and compress video
  Future<Map<String, String>?> uploadReelVideo({
    required String filePath,
    required String fileName,
  }) async {
    try {
      print('=== Upload Reel Video ===');
      print('File path: $filePath');
      print('File name: $fileName');
      
      // Check if running on web
      if (kIsWeb) {
        throw Exception('Video compression is not supported on web platform. Please use mobile app.');
      }
      
      // Get video duration first
      print('Getting video duration...');
      final mediaInfo = await VideoCompress.getMediaInfo(filePath);
      final duration = mediaInfo.duration != null ? (mediaInfo.duration! / 1000).round() : 0;
      
      print('Video duration: $duration seconds');
      
      // Trim video to 10 seconds if longer
      MediaInfo? info;
      if (duration > 10) {
        print('Video is longer than 10 seconds, trimming to first 10 seconds...');
        info = await VideoCompress.compressVideo(
          filePath,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: false,
          includeAudio: true,
          startTime: 0,
          duration: 10, // Trim to 10 seconds
        );
      } else {
        print('Video is within 10 seconds, compressing...');
        info = await VideoCompress.compressVideo(
          filePath,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: false,
          includeAudio: true,
        );
      }

      if (info == null || info.file == null) {
        throw Exception('Failed to compress video');
      }

      print('Video compressed successfully');
      print('Original size: ${File(filePath).lengthSync()} bytes');
      print('Compressed size: ${info.filesize} bytes');

      // Get compressed video file
      final compressedFile = info.file!;
      
      // Upload compressed video to Supabase Storage
      print('Uploading video to Supabase...');
      final videoBytes = await compressedFile.readAsBytes();
      final videoFileName = 'reel_${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final videoPath = 'reels/$videoFileName';

      try {
        await _supabase.storage
            .from('videos')
            .uploadBinary(videoPath, videoBytes);
      } catch (e) {
        throw Exception('Failed to upload video to storage: $e. Please check if "videos" bucket exists and is public.');
      }

      final videoUrl = _supabase.storage
          .from('videos')
          .getPublicUrl(videoPath);

      print('Video uploaded: $videoUrl');

      // Generate and upload thumbnail
      print('Generating thumbnail...');
      final thumbnail = await VideoCompress.getFileThumbnail(
        compressedFile.path,
        quality: 50,
      );

      String thumbnailUrl = '';
      final thumbnailBytes = await thumbnail.readAsBytes();
      final thumbnailFileName = 'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final thumbnailPath = 'reels/thumbnails/$thumbnailFileName';

      try {
        await _supabase.storage
            .from('videos')
            .uploadBinary(thumbnailPath, thumbnailBytes);
      } catch (e) {
        print('Warning: Failed to upload thumbnail: $e');
        // Continue without thumbnail
      }

      thumbnailUrl = _supabase.storage
          .from('videos')
          .getPublicUrl(thumbnailPath);

      print('Thumbnail uploaded: $thumbnailUrl');
      print('=== Upload Complete ===');

      return {
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
      };
    } catch (e) {
      print('=== ERROR Uploading Reel Video ===');
      print('Error: $e');
      return null;
    }
  }

  // Get video duration in seconds
  Future<int> getVideoDuration(String filePath) async {
    try {
      if (kIsWeb) {
        // Web platform doesn't support video_compress
        print('Video duration check not available on web');
        return 0;
      }
      
      final info = await VideoCompress.getMediaInfo(filePath);
      if (info.duration != null) {
        return (info.duration! / 1000).round(); // Convert milliseconds to seconds
      }
      return 0;
    } catch (e) {
      print('Error getting video duration: $e');
      return 0;
    }
  }

  // Create a new reel
  Future<ReelModel?> createReel({
    required String videoUrl,
    required String thumbnailUrl,
    required int duration,
    String? caption,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'user_id': userId,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'caption': caption,
        'duration': duration,
      };

      final response = await _supabase
          .from('reels')
          .insert(data)
          .select()
          .single();

      // Get user profile
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ReelModel.fromJson(response, profile);
    } catch (e) {
      print('Error creating reel: $e');
      return null;
    }
  }

  // Get all reels
  Future<List<ReelModel>> getReels() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      final response = await _supabase
          .from('reels')
          .select()
          .order('created_at', ascending: false);

      List<ReelModel> reels = [];
      
      for (var reel in response) {
        // Get user profile
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', reel['user_id'])
            .single();

        // Check if user has liked this reel
        bool isLiked = false;
        if (userId != null) {
          final likeCheck = await _supabase
              .from('reel_likes')
              .select()
              .eq('reel_id', reel['id'])
              .eq('user_id', userId)
              .maybeSingle();
          
          isLiked = likeCheck != null;
        }

        reel['is_liked'] = isLiked;
        reels.add(ReelModel.fromJson(reel, profile));
      }

      return reels;
    } catch (e) {
      print('Error getting reels: $e');
      return [];
    }
  }

  // Get user's reels
  Future<List<ReelModel>> getUserReels(String userId) async {
    try {
      final response = await _supabase
          .from('reels')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response
          .map<ReelModel>((reel) => ReelModel.fromJson(reel, profile))
          .toList();
    } catch (e) {
      print('Error getting user reels: $e');
      return [];
    }
  }

  // Like a reel
  Future<bool> likeReel(String reelId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('reel_likes').insert({
        'reel_id': reelId,
        'user_id': userId,
      });

      return true;
    } catch (e) {
      print('Error liking reel: $e');
      return false;
    }
  }

  // Unlike a reel
  Future<bool> unlikeReel(String reelId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('reel_likes')
          .delete()
          .eq('reel_id', reelId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error unliking reel: $e');
      return false;
    }
  }

  // Add view to reel
  Future<void> addReelView(String reelId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Check if user has already viewed this reel
      final existingView = await _supabase
          .from('reel_views')
          .select()
          .eq('reel_id', reelId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingView == null) {
        await _supabase.from('reel_views').insert({
          'reel_id': reelId,
          'user_id': userId,
        });
      }
    } catch (e) {
      print('Error adding reel view: $e');
    }
  }

  // Delete a reel
  Future<bool> deleteReel(String reelId) async {
    try {
      await _supabase
          .from('reels')
          .delete()
          .eq('id', reelId);

      return true;
    } catch (e) {
      print('Error deleting reel: $e');
      return false;
    }
  }

  // ==================== COMMENT FUNCTIONS ====================

  // Add comment to reel
  Future<Map<String, dynamic>?> addComment({
    required String reelId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final data = {
        'reel_id': reelId,
        'user_id': userId,
        'content': content,
        if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      };

      final response = await _supabase
          .from('reel_comments')
          .insert(data)
          .select()
          .single();

      // Get user profile
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      response['user_name'] = profile['name'];
      response['user_avatar'] = profile['avatar_url'];

      return response;
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }

  // Get comments for a reel
  Future<List<Map<String, dynamic>>> getComments(String reelId) async {
    try {
      final response = await _supabase
          .from('reel_comments')
          .select()
          .eq('reel_id', reelId)
          .filter('parent_comment_id', 'is', null)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> comments = [];
      
      for (var comment in response) {
        // Get user profile
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', comment['user_id'])
            .single();

        comment['user_name'] = profile['name'];
        comment['user_avatar'] = profile['avatar_url'];

        // Get replies count
        final repliesCount = await _supabase
            .from('reel_comments')
            .select()
            .eq('parent_comment_id', comment['id'])
            .count();

        comment['replies_count'] = repliesCount.count;
        comments.add(comment);
      }

      return comments;
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  // Get replies for a comment
  Future<List<Map<String, dynamic>>> getReplies(String commentId) async {
    try {
      final response = await _supabase
          .from('reel_comments')
          .select()
          .eq('parent_comment_id', commentId)
          .order('created_at', ascending: true);

      List<Map<String, dynamic>> replies = [];
      
      for (var reply in response) {
        // Get user profile
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', reply['user_id'])
            .single();

        reply['user_name'] = profile['name'];
        reply['user_avatar'] = profile['avatar_url'];
        replies.add(reply);
      }

      return replies;
    } catch (e) {
      print('Error getting replies: $e');
      return [];
    }
  }

  // Delete comment
  Future<bool> deleteComment(String commentId) async {
    try {
      await _supabase
          .from('reel_comments')
          .delete()
          .eq('id', commentId);

      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }
}
