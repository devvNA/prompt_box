import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_stats_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  /// Calls RPC get_profile_stats for the given [userId].
  /// Returns empty [ProfileStatsModel] if [userId] is empty or call fails.
  Future<ProfileStatsModel> getProfileStats(String userId) async {
    if (userId.trim().isEmpty) {
      return const ProfileStatsModel();
    }

    try {
      final response = await _supabase.rpc(
        'get_profile_stats',
        params: {'target_user_id': userId},
      );

      if (response == null) {
        return const ProfileStatsModel();
      }

      if (response is Map<String, dynamic>) {
        return ProfileStatsModel.fromMap(response);
      } else if (response is Map) {
        return ProfileStatsModel.fromMap(Map<String, dynamic>.from(response));
      }

      return const ProfileStatsModel();
    } catch (_) {
      return const ProfileStatsModel();
    }
  }

  /// Helper to get profile stats for the currently authenticated Supabase user.
  Future<ProfileStatsModel> getCurrentUserProfileStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return const ProfileStatsModel();
    }
    return getProfileStats(user.id);
  }
}
