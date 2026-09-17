class PromptModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final String? resultImageUrl;
  final bool isPublic;
  final DateTime? createdAt;
  final int likes;
  final String? userId;
  final String? authorName;
  final String? authorAvatar;
  final bool isLiked;
  final bool isBookmarked;

  const PromptModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
    this.resultImageUrl,
    this.isPublic = true,
    this.createdAt,
    this.likes = 0,
    this.userId,
    this.authorName,
    this.authorAvatar,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  bool get hasImage =>
      resultImageUrl != null && resultImageUrl!.trim().isNotEmpty;

  PromptModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    String? resultImageUrl,
    bool? isPublic,
    DateTime? createdAt,
    int? likes,
    String? userId,
    String? authorName,
    String? authorAvatar,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return PromptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      resultImageUrl: resultImageUrl ?? this.resultImageUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'result_image_url': resultImageUrl,
      'is_public': isPublic,
      'created_at': createdAt?.toIso8601String(),
      'likes': likes,
      'user_id': userId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'is_liked': isLiked,
      'is_bookmarked': isBookmarked,
    };
  }

  factory PromptModel.fromMap(Map<String, dynamic> map) {
    // Extract category name if joined from Supabase 'categories' table
    String category = 'Image Generation';
    if (map['categories'] is Map<String, dynamic>) {
      category = (map['categories']['name'] ?? 'Image Generation') as String;
    } else if (map['category'] != null) {
      category = map['category'] as String;
    }

    // Extract tags if joined from Supabase 'prompt_tags' table
    List<String> tags = [];
    if (map['prompt_tags'] is List) {
      tags = (map['prompt_tags'] as List)
          .map((item) {
            if (item is Map) {
              if (item['tags'] is Map) {
                return item['tags']['name']?.toString() ?? '';
              }
              return item['name']?.toString() ?? '';
            }
            return item.toString();
          })
          .where((t) => t.trim().isNotEmpty)
          .toList();
    } else if (map['tags'] is List) {
      tags = (map['tags'] as List).map((e) => e.toString()).toList();
    }

    // Extract author name & avatar if joined from Supabase 'profiles' table
    String authorName = 'Devit Nur Azaqi';
    String? authorAvatar;
    if (map['profiles'] is Map<String, dynamic>) {
      authorName =
          (map['profiles']['username'] ?? 'Devit Nur Azaqi') as String;
      authorAvatar = map['profiles']['avatar_url'] as String?;
    } else {
      if (map['author_name'] != null) {
        authorName = map['author_name'] as String;
      } else if (map['author'] != null) {
        authorName = map['author'] as String;
      }
      if (map['author_avatar'] != null) {
        authorAvatar = map['author_avatar'] as String?;
      }
    }

    // Parse createdAt
    DateTime? createdAt;
    if (map['created_at'] is DateTime) {
      createdAt = map['created_at'] as DateTime;
    } else if (map['created_at'] is String) {
      createdAt = DateTime.tryParse(map['created_at'] as String);
    }

    // Parse likes count
    int likesCount = 0;
    if (map['likes'] is int) {
      likesCount = map['likes'] as int;
    } else if (map['likes'] is List && (map['likes'] as List).isNotEmpty) {
      final first = (map['likes'] as List).first;
      if (first is Map && first['count'] != null) {
        likesCount = (first['count'] as num).toInt();
      }
    } else if (map['likes_count'] is num) {
      likesCount = (map['likes_count'] as num).toInt();
    }

    bool isLiked = false;
    if (map['is_liked'] is bool) {
      isLiked = map['is_liked'] as bool;
    }

    // Parse is_bookmarked
    bool isBookmarked = false;
    if (map['is_bookmarked'] is bool) {
      isBookmarked = map['is_bookmarked'] as bool;
    }

    return PromptModel(
      id: (map['id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      content: (map['content'] ?? '') as String,
      category: category,
      tags: tags,
      resultImageUrl: map['result_image_url'] as String?,
      isPublic: (map['is_public'] ?? true) as bool,
      createdAt: createdAt,
      likes: likesCount,
      userId: (map['owner_id'] ?? map['user_id']) as String?,
      authorName: authorName,
      authorAvatar: authorAvatar,
      isLiked: isLiked,
      isBookmarked: isBookmarked,
    );
  }
}
