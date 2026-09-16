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

    // Extract author name if joined from Supabase 'profiles' table
    String authorName = 'Devit Nur Azaqi';
    if (map['profiles'] is Map<String, dynamic>) {
      authorName =
          (map['profiles']['username'] ?? 'Devit Nur Azaqi') as String;
    } else if (map['author_name'] != null) {
      authorName = map['author_name'] as String;
    } else if (map['author'] != null) {
      authorName = map['author'] as String;
    }

    // Parse createdAt
    DateTime? createdAt;
    if (map['created_at'] is DateTime) {
      createdAt = map['created_at'] as DateTime;
    } else if (map['created_at'] is String) {
      createdAt = DateTime.tryParse(map['created_at'] as String);
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
      likes: (map['likes'] ?? 0) as int,
      userId: (map['owner_id'] ?? map['user_id']) as String?,
      authorName: authorName,
    );
  }
}
