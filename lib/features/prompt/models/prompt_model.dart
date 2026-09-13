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
    return PromptModel(
      id: (map['id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      content: (map['content'] ?? '') as String,
      category: (map['category'] ?? 'Image Generation') as String,
      tags:
          (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      resultImageUrl: map['result_image_url'] as String?,
      isPublic: (map['is_public'] ?? true) as bool,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      likes: (map['likes'] ?? 0) as int,
      userId: map['user_id'] as String?,
      authorName: map['author_name'] as String? ?? 'Devit Nur Azaqi',
    );
  }
}
