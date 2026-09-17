import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/supabase_provider.dart';
import '../models/profile_stats_model.dart';
import '../repositories/profile_repository.dart';
import '../../prompt/models/prompt_model.dart';
import '../../prompt/providers/prompt_provider.dart';

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ProfileRepository(supabase);
});

/// AsyncNotifier provider for current user's profile statistics
final profileStatsNotifierProvider =
    AsyncNotifierProvider<ProfileStatsNotifier, ProfileStatsModel>(
      ProfileStatsNotifier.new,
    );

class ProfileStatsNotifier extends AsyncNotifier<ProfileStatsModel> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  Future<ProfileStatsModel> build() async {
    final user = ref.watch(supabaseClientProvider).auth.currentUser;
    if (user == null) {
      return const ProfileStatsModel();
    }
    return _repository.getProfileStats(user.id);
  }

  /// Manually refresh stats from Supabase
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(supabaseClientProvider).auth.currentUser;
      if (user == null) {
        return const ProfileStatsModel();
      }
      return _repository.getProfileStats(user.id);
    });
  }
}

/// AsyncNotifier provider for bookmarked prompts
final bookmarkedPromptsNotifierProvider =
    AsyncNotifierProvider<BookmarkedPromptsNotifier, List<PromptModel>>(
  BookmarkedPromptsNotifier.new,
);

class BookmarkedPromptsNotifier extends AsyncNotifier<List<PromptModel>> {
  @override
  Future<List<PromptModel>> build() async {
    return ref.read(promptRepositoryProvider).getBookmarkedPrompts();
  }

  /// Manually refresh bookmarked prompts
  Future<void> refresh() async {
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
