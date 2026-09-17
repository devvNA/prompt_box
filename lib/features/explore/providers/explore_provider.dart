import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prompt/models/prompt_model.dart';
import '../../prompt/providers/prompt_provider.dart';
import '../../prompt/repositories/prompt_repository.dart';

/// Provider for managing the list of public community prompts in the Explore tab.
final explorePromptsNotifierProvider =
    AsyncNotifierProvider<ExplorePromptsNotifier, List<PromptModel>>(
      ExplorePromptsNotifier.new,
    );

class ExplorePromptsNotifier extends AsyncNotifier<List<PromptModel>> {
  PromptRepository get _repository => ref.read(promptRepositoryProvider);

  @override
  Future<List<PromptModel>> build() async {
    return _repository.getPublicPrompts();
  }

  /// Refreshes the public prompts from Supabase.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getPublicPrompts());
  }

  /// Updates a single prompt in local state directly without refetching.
  void updatePrompt(PromptModel updatedPrompt) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current
            .map((p) => p.id == updatedPrompt.id ? updatedPrompt : p)
            .toList(),
      );
    }
  }

  /// Toggles like status for a prompt and optimistically/reactively updates the state.
  Future<Map<String, dynamic>> toggleLike(String promptId) async {
    final current = state.value;
    PromptModel? target;
    if (current != null) {
      for (final p in current) {
        if (p.id == promptId) {
          target = p;
          break;
        }
      }
    }

    // Optimistically update local list state
    if (current != null && target != null) {
      final nextLiked = !target.isLiked;
      final nextCount =
          (target.likes + (nextLiked ? 1 : -1)).clamp(0, 999999);
      state = AsyncData(
        current
            .map(
              (p) => p.id == promptId
                  ? p.copyWith(isLiked: nextLiked, likes: nextCount)
                  : p,
            )
            .toList(),
      );
    }

    try {
      final result = await _repository.toggleLike(promptId);
      final isLiked = result['is_liked'] as bool? ?? false;
      final likeCount = (result['like_count'] as num?)?.toInt() ?? 0;

      final updated = state.value;
      if (updated != null) {
        state = AsyncData(
          updated.map((p) {
            if (p.id == promptId) {
              return p.copyWith(isLiked: isLiked, likes: likeCount);
            }
            return p;
          }).toList(),
        );
      }

      return result;
    } catch (e) {
      // Revert if network call failed
      if (current != null) {
        state = AsyncData(current);
      }
      rethrow;
    }
  }
}
