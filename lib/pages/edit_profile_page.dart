import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsi/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  Map<String, dynamic>? _userProfile;
  String? _newAvatarPath;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _authService.getCurrentUserProfile();

      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile['name'] ?? '';
          _usernameController.text = profile['username'] ?? '';
          _bioController.text = profile['bio'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      await _authService.updateProfile(
        name: _nameController.text,
        bio: _bioController.text,
      );

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit profile',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          _isSaving
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6C5CE7),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.check, color: Colors.black, size: 28),
                  onPressed: _saveProfile,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Photo
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _userProfile?['avatar_url'] != null &&
                          _userProfile!['avatar_url'].isNotEmpty
                      ? NetworkImage(_userProfile!['avatar_url'])
                      : null,
                  backgroundColor: Colors.grey[300],
                  child:
                      _userProfile?['avatar_url'] == null ||
                          _userProfile!['avatar_url'].isEmpty
                      ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                      : null,
                ),
              ],
            ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: _changeProfilePhoto,
              child: Text(
                'Change profile photo',
                style: TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: 30),

            // Name Field
            _buildTextField(label: 'Name', controller: _nameController),

            SizedBox(height: 20),

            // Username Field (Read-only)
            _buildTextField(
              label: 'Username (cannot be changed)',
              controller: _usernameController,
              enabled: false,
            ),

            SizedBox(height: 20),

            // Website Field
            _buildTextField(label: 'Website', controller: _websiteController),

            SizedBox(height: 20),

            // Bio Field
            _buildTextField(
              label: 'Bio',
              controller: _bioController,
              maxLines: 3,
            ),

            SizedBox(height: 20),

            // Add Link
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add Link',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),

            SizedBox(height: 30),

            // Action Links
            _buildActionLink('Switch to professional account', () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Switch to professional account')),
              );
            }),

            SizedBox(height: 20),

            _buildActionLink('Create avatar', () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Create avatar')));
            }),

            SizedBox(height: 20),

            _buildActionLink('Personal information settings', () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Personal information settings')),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            filled: !enabled,
            fillColor: !enabled ? Colors.grey[100] : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF6C5CE7), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildActionLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF6C5CE7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _changeProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFF6C5CE7)),
              title: Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFF6C5CE7)),
              title: Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            if (_userProfile?['avatar_url'] != null && _userProfile!['avatar_url'].isNotEmpty)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await _removeAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() => _isUploadingAvatar = true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Uploading avatar...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );

        // Read bytes from XFile (works on web and mobile)
        final bytes = await image.readAsBytes();
        final fileExt = image.name.split('.').last;
        
        // Upload to Supabase
        final avatarUrl = await _authService.uploadAvatar(bytes, fileExt);
        
        if (avatarUrl != null) {
          // Update profile with new avatar URL
          await _authService.updateProfile(avatarUrl: avatarUrl);
          
          // Reload profile
          await _loadUserProfile();
          
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile photo updated!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload photo'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        
        setState(() => _isUploadingAvatar = false);
      }
    } catch (e) {
      print('Error uploading avatar: $e');
      setState(() => _isUploadingAvatar = false);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _isUploadingAvatar = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('Removing photo...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    final success = await _authService.removeAvatar();
    
    if (success) {
      await _loadUserProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo removed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isUploadingAvatar = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _websiteController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
