import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_stats_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  /// Calls RPC get_profile_stats for the given [userId].
  Future<ProfileStatsModel> getProfileStats(String userId) async {
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
  }
}
