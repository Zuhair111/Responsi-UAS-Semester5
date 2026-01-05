class PostModel {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final String privacy;
  final String? location;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final String userName;
  final String? userAvatarUrl;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.privacy,
    this.location,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.userName,
    this.userAvatarUrl,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, Map<String, dynamic>? profile) {
    return PostModel(
      id: json['id'].toString(),
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      privacy: json['privacy'] ?? 'public',
      location: json['location'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      userName: profile?['name'] ?? 'Unknown User',
      userAvatarUrl: profile?['avatar_url'],
    );
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    return PostModel(
      id: map['id'].toString(),
      userId: map['user_id'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['image_url'],
      privacy: map['privacy'] ?? 'public',
      location: map['location'],
      likesCount: map['like_count'] ?? map['likes_count'] ?? 0,
      commentsCount: map['comment_count'] ?? map['comments_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      userName: profile?['name'] ?? profile?['username'] ?? 'Unknown User',
      userAvatarUrl: profile?['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'privacy': privacy,
      'location': location,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'privacy': privacy,
      'location': location,
      'like_count': likesCount,
      'comment_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'profiles': {
        'name': userName,
        'avatar_url': userAvatarUrl,
      },
    };
  }

  // Helper untuk format waktu
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
