import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/supabase_provider.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/profile_stats_model.dart';
import '../repositories/profile_repository.dart';
import '../../prompt/models/prompt_model.dart';
import '../../prompt/providers/prompt_provider.dart';

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ProfileRepository(supabase);
});

/// AsyncNotifier provider for current user's profile statistics.
/// Automatically updates when a user logs in and clears when logged out.
final profileStatsNotifierProvider =
    AsyncNotifierProvider<ProfileStatsNotifier, ProfileStatsModel>(
      ProfileStatsNotifier.new,
    );

class ProfileStatsNotifier extends AsyncNotifier<ProfileStatsModel> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  Future<ProfileStatsModel> build() async {
    // React to auth state changes and user ID changes
    final authState = ref.watch(authNotifierProvider);
    final userId = ref.watch(currentUserIdProvider);

    // If unauthenticated or no valid user ID, immediately wipe/return empty stats
    if (authState.status != AuthStatus.authenticated ||
        userId == null ||
        userId.trim().isEmpty) {
      return const ProfileStatsModel();
    }

    return _repository.getProfileStats(userId);
  }

  /// Explicitly reset/delete profile stats state (called on logout)
  void clear() {
    state = const AsyncData(ProfileStatsModel());
  }

  /// Manually refresh stats from Supabase for current user
  Future<void> refresh() async {
    final authState = ref.read(authNotifierProvider);
    final userId = ref.read(currentUserIdProvider);

    if (authState.status != AuthStatus.authenticated ||
        userId == null ||
        userId.trim().isEmpty) {
      state = const AsyncData(ProfileStatsModel());
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _repository.getProfileStats(userId);
    });
  }
}

/// AsyncNotifier provider for bookmarked prompts.
/// Automatically updates when a user logs in and clears when logged out.
final bookmarkedPromptsNotifierProvider =
    AsyncNotifierProvider<BookmarkedPromptsNotifier, List<PromptModel>>(
  BookmarkedPromptsNotifier.new,
);

class BookmarkedPromptsNotifier extends AsyncNotifier<List<PromptModel>> {
  @override
  Future<List<PromptModel>> build() async {
    final authState = ref.watch(authNotifierProvider);
    final userId = ref.watch(currentUserIdProvider);

    if (authState.status != AuthStatus.authenticated ||
        userId == null ||
        userId.trim().isEmpty) {
      return const [];
    }

    return ref.read(promptRepositoryProvider).getBookmarkedPrompts();
  }

  /// Explicitly clear bookmarked prompts state (called on logout)
  void clear() {
    state = const AsyncData([]);
  }

  /// Manually refresh bookmarked prompts
  Future<void> refresh() async {
    final authState = ref.read(authNotifierProvider);
    final userId = ref.read(currentUserIdProvider);

    if (authState.status != AuthStatus.authenticated ||
        userId == null ||
        userId.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(promptRepositoryProvider).getBookmarkedPrompts(),
    );
  }

  /// Optimistically remove a prompt from the bookmarked list
  void removeBookmarkLocally(String promptId) {
    if (state.value != null) {
      final currentList = state.value!;
      state = AsyncData(currentList.where((p) => p.id != promptId).toList());
    }
  }

  /// Optimistically add a prompt to the bookmarked list
  void addBookmarkLocally(PromptModel prompt) {
    if (state.value != null) {
      final currentList = state.value!;
      if (!currentList.any((p) => p.id == prompt.id)) {
        state = AsyncData([prompt.copyWith(isBookmarked: true), ...currentList]);
      }
    }
  }
}
