class ReelModel {
  final String id;
  final String userId;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? caption;
  final int duration; // Duration in seconds
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final DateTime createdAt;
  final String userName;
  final String? userAvatarUrl;
  final bool? isLiked; // Whether current user has liked this reel

  ReelModel({
    required this.id,
    required this.userId,
    required this.videoUrl,
    this.thumbnailUrl,
    this.caption,
    required this.duration,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.createdAt,
    required this.userName,
    this.userAvatarUrl,
    this.isLiked,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json, Map<String, dynamic>? profile) {
    return ReelModel(
      id: json['id'].toString(),
      userId: json['user_id'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      caption: json['caption'],
      duration: json['duration'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      userName: profile?['name'] ?? 'Unknown User',
      userAvatarUrl: profile?['avatar_url'],
      isLiked: json['is_liked'],
    );
  }

  factory ReelModel.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    return ReelModel(
      id: map['id'].toString(),
      userId: map['user_id'] ?? '',
      videoUrl: map['video_url'] ?? '',
      thumbnailUrl: map['thumbnail_url'],
      caption: map['caption'],
      duration: map['duration'] ?? 0,
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      viewsCount: map['views_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      userName: profile?['name'] ?? profile?['username'] ?? 'Unknown User',
      userAvatarUrl: profile?['avatar_url'],
      isLiked: map['is_liked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'caption': caption,
      'duration': duration,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'views_count': viewsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReelModel copyWith({
    String? id,
    String? userId,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    int? duration,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    DateTime? createdAt,
    String? userName,
    String? userAvatarUrl,
    bool? isLiked,
  }) {
    return ReelModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      duration: duration ?? this.duration,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
