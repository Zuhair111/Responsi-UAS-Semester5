import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../services/post_service.dart';
import '../services/auth_service.dart';
import 'create_reel_page.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _postController = TextEditingController();
  final PostService _postService = PostService();
  final AuthService _authService = AuthService();
  
  String _selectedPrivacy = 'Friends';
  String _selectedAlbum = 'Album'; 
  bool _isLocationOn = false;
  bool _isLoading = false;
  
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  String? _userName;
  String? _userAvatar;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _authService.getCurrentUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _userName = profile['name'] ?? 'User';
        _userAvatar = profile['avatar_url'];
      });
    }
  }

  Future<void> _handleCreatePost() async {
    if (_postController.text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content or image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      
      // Upload image if selected
      if (_selectedImage != null && _imageBytes != null) {
        imageUrl = await _postService.uploadImage(
          imageBytes: _imageBytes!,
          fileName: _selectedImage!.name,
        );
      }

      // Create post
      final post = await _postService.createPost(
        content: _postController.text,
        imageUrl: imageUrl,
        privacy: _selectedPrivacy.toLowerCase(),
        location: _isLocationOn ? 'Location enabled' : null,
      );

      if (post != null && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleCreatePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A3E9E), 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'POST',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _userAvatar != null
                        ? NetworkImage(_userAvatar!)
                        : const NetworkImage(
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName ?? 'User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Menggunakan Wrap untuk menghindari overflow
                        Wrap(
                          spacing: 8.0, // Jarak horizontal antar tombol
                          runSpacing: 4.0, // Jarak vertikal jika tombol wrap
                          children: [
                            _buildDropdownButton(
                              icon: Icons.people,
                              text: _selectedPrivacy,
                              onTap: () => _showPrivacyOptions(),
                            ),
                            _buildDropdownButton(
                              // Mengubah ikon album sesuai gambar
                              icon: Icons.photo_album, 
                              text: _selectedAlbum,
                              onTap: () => _showAlbumOptions(),
                            ),
                            _buildDropdownButton(
                              // Mengubah ikon lokasi sesuai gambar
                              icon: Icons.camera_alt_outlined, 
                              text: _isLocationOn ? 'On' : 'Off', // Teks default "Off"
                              onTap: () => _toggleLocation(),
                              // Warna ikon lokasi
                              iconColor: _isLocationOn ? Colors.green[700] : Colors.grey[700], 
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Text Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _postController,
                maxLines: 8, // Dapat disesuaikan
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18, // Font size yang lebih besar seperti di gambar
                    fontWeight: FontWeight.w500, // Sedikit lebih tebal
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Selected Image Preview
            if (_imageBytes != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _imageBytes!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeSelectedImage,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),

            Divider(thickness: 8, color: Colors.grey[100]),

            // Action Buttons
            _buildActionButton(
              icon: Icons.photo_library,
              text: 'Photo/Video',
              // Warna dari gambar: merah/oranye
              color: Color(0xFFFF8A5B), 
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            _buildActionButton(
              icon: Icons.video_library,
              text: 'Create Reel',
              // Warna dari gambar: merah/oranye
              color: Color(0xFFFF8A5B), 
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateReelPage()),
                );
                if (result == true) {
                  Navigator.pop(context, true);
                }
              },
            ),
            Divider(height: 1, color: Colors.grey[200]),
            _buildActionButton(
              icon: Icons.camera_alt,
              text: 'Camera',
              // Warna dari gambar: merah/oranye
              color: Color(0xFFFF8A5B), 
              onTap: () => _pickImage(ImageSource.camera),
            ),
             Divider(height: 1, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? iconColor, 
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor ?? Colors.grey[700], 
            ),
            SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showPrivacyOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Privacy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.public),
              title: Text('Public'),
              onTap: () {
                setState(() => _selectedPrivacy = 'Public');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Friends'),
              onTap: () {
                setState(() => _selectedPrivacy = 'Friends');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Only Me'),
              onTap: () {
                setState(() => _selectedPrivacy = 'Only Me');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAlbumOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Album',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              // Ikon dari gambar
              leading: Icon(Icons.phone_android), 
              title: Text('Mobile'),
              onTap: () {
                setState(() => _selectedAlbum = 'Mobile');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Profile'),
              onTap: () {
                setState(() => _selectedAlbum = 'Profile');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.collections),
              title: Text('Timeline'),
              onTap: () {
                setState(() => _selectedAlbum = 'Timeline');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLocation() {
    setState(() {
      _isLocationOn = !_isLocationOn;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected: ${image.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}