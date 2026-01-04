import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  // Sign Up dengan email dan password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    print('=== Starting signup process ===');
    print('Email: $email, Name: $name');

    // Signup auth
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    print('Auth signup response: ${response.user?.id}');
    print('Response session: ${response.session}');

    // Tunggu sebentar untuk trigger database
    await Future.delayed(Duration(milliseconds: 500));

    // Cek apakah profile sudah dibuat oleh trigger
    if (response.user != null) {
      final existingProfile = await _checkProfileExists(response.user!.id);

      if (!existingProfile) {
        print('Profile not created by trigger, creating manually...');
        // Buat profile secara manual
        await _createProfile(
          userId: response.user!.id,
          email: email,
          name: name,
        );
      } else {
        print('Profile already created by trigger');
      }
    }

    return response;
  }

  // Helper: Cek apakah profile sudah ada
  Future<bool> _checkProfileExists(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('Error checking profile: $e');
      return false;
    }
  }

  // Helper: Buat profile baru
  Future<void> _createProfile({
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      final username = email.split('@')[0];
      await _client.from('profiles').insert({
        'id': userId,
        'username': username,
        'name': name,
        'email': email,
        'bio': '',
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('Profile created successfully for user: $userId');
    } catch (e) {
      print('Error creating profile: $e');
      rethrow;
    }
  }

  // Sign In dengan email dan password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Cek apakah profile ada, jika tidak buat otomatis
      if (response.user != null) {
        final hasProfile = await _checkProfileExists(response.user!.id);
        if (!hasProfile) {
          print('Profile not found, creating profile for existing user...');
          // Ambil nama dari email sebagai fallback
          final name = email.split('@')[0];
          await _createProfile(
            userId: response.user!.id,
            email: email,
            name: name,
          );
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      print('getCurrentUserProfile: No user logged in');
      return null;
    }

    try {
      print('Fetching profile for user: ${user.id}');
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        print('Profile not found, creating profile...');
        // Buat profile baru jika tidak ada
        await _createProfile(
          userId: user.id,
          email: user.email ?? '',
          name: user.email?.split('@')[0] ?? 'User',
        );

        // Fetch ulang setelah dibuat
        final newProfile = await _client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        print('Profile created and fetched: $newProfile');
        return newProfile;
      }

      print('Profile fetched successfully: $response');
      return response;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Get any user profile by user ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print('Fetching profile for user: $userId');
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      print('Profile fetched: $response');
      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Search users by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      print('🔍 Searching users with query: $query');
      
      final response = await _client
          .from('profiles')
          .select('id, username, name, avatar_url, bio')
          .ilike('username', '%$query%')
          .limit(20);

      print('✅ Found ${response.length} users');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
    String? bio,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) updates['name'] = name;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (bio != null) updates['bio'] = bio;

    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  // Upload avatar image
  Future<String?> uploadAvatar(Uint8List bytes, String fileExtension) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return null;
      }

      print('📸 Uploading avatar for user: ${user.id}');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.id}/avatar_$timestamp.$fileExtension';

      print('📁 File name: $fileName');

      // Upload to Supabase Storage
      await _client.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      print('✅ Avatar uploaded to storage');

      // Get public URL
      final imageUrl = _client.storage.from('avatars').getPublicUrl(fileName);
      print('🔗 Avatar URL: $imageUrl');

      return imageUrl;
    } catch (e) {
      print('❌ Error uploading avatar: $e');
      return null;
    }
  }

  // Remove avatar
  Future<bool> removeAvatar() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Get current profile to find avatar URL
      final profile = await getCurrentUserProfile();
      if (profile?['avatar_url'] != null) {
        final avatarUrl = profile!['avatar_url'] as String;
        final uri = Uri.parse(avatarUrl);
        final pathSegments = uri.pathSegments;
        
        if (pathSegments.isNotEmpty) {
          final fileName = pathSegments.skip(pathSegments.length - 2).join('/');
          print('🗑️ Deleting avatar: $fileName');
          
          try {
            await _client.storage.from('avatars').remove([fileName]);
            print('✅ Avatar deleted from storage');
          } catch (storageError) {
            print('⚠️ Could not delete from storage: $storageError');
          }
        }
      }

      // Update profile to remove avatar_url
      await updateProfile(avatarUrl: '');
      return true;
    } catch (e) {
      print('❌ Error removing avatar: $e');
      return false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;
}
