class ProfileStatsModel {
  final int totalPrompts;
  final int totalLikes;
  final int totalCollections;
  final int totalViews;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final DateTime? createdAt;

  const ProfileStatsModel({
    this.totalPrompts = 0,
    this.totalLikes = 0,
    this.totalCollections = 0,
    this.totalViews = 0,
    this.username,
    this.avatarUrl,
    this.bio,
    this.createdAt,
  });

  /// Factory constructor to parse JSON returned from get_profile_stats RPC
  factory ProfileStatsModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    if (map['created_at'] is DateTime) {
      parsedCreatedAt = map['created_at'] as DateTime;
    } else if (map['created_at'] is String) {
      parsedCreatedAt = DateTime.tryParse(map['created_at'] as String);
    }

    return ProfileStatsModel(
      totalPrompts: (map['total_prompts'] as num?)?.toInt() ?? 0,
      totalLikes: (map['total_likes'] as num?)?.toInt() ?? 0,
      totalCollections: (map['total_collections'] as num?)?.toInt() ?? 0,
      totalViews: (map['total_views'] as num?)?.toInt() ?? 0,
      username: map['username'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      createdAt: parsedCreatedAt,
    );
  }

  /// Compact string formatting for display (e.g. 42, 1.2k, 10.5k, 1.5M)
  static String formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      final value = count / 1000.0;
      return value % 1 == 0
          ? '${value.toInt()}k'
          : '${value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
    } else {
      final value = count / 1000000.0;
      return value % 1 == 0
          ? '${value.toInt()}M'
          : '${value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    }
  }

  String get formattedPrompts => formatCount(totalPrompts);
  String get formattedLikes => formatCount(totalLikes);
  String get formattedCollections => formatCount(totalCollections);
  String get formattedViews => formatCount(totalViews);
}
