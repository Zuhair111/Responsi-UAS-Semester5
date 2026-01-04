class StoryModel {
  final String id;
  final String userId;
  final String? username;
  final String? avatarUrl;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isViewed; // Track if current user has viewed this story

  StoryModel({
    required this.id,
    required this.userId,
    this.username,
    this.avatarUrl,
    required this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
    this.isViewed = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['user'] != null ? json['user']['username'] as String? : null,
      avatarUrl: json['user'] != null ? json['user']['avatar_url'] as String? : null,
      imageUrl: json['image_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isViewed: json['is_viewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
