import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/supabase_provider.dart';
import '../models/prompt_model.dart';
import '../repositories/prompt_repository.dart';

/// Provider for the PromptRepository instance
final promptRepositoryProvider = Provider<PromptRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PromptRepository(supabase);
});

/// Provider for managing the list of user's prompts
final promptListNotifierProvider =
    AsyncNotifierProvider<PromptListNotifier, List<PromptModel>>(
      PromptListNotifier.new,
    );

class PromptListNotifier extends AsyncNotifier<List<PromptModel>> {
  PromptRepository get _repository => ref.read(promptRepositoryProvider);

  @override
  Future<List<PromptModel>> build() async {
    return _repository.getUserPrompts();
  }

  /// Creates a new prompt, saves it to Supabase, and updates local state.
  Future<PromptModel> createPrompt({
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    Uint8List? imageBytes,
    String? imageUrl,
    required bool isPublic,
  }) async {
    final created = await _repository.createPrompt(
      title: title,
      content: content,
      category: category,
      tags: tags,
      imageBytes: imageBytes,
      imageUrl: imageUrl,
      isPublic: isPublic,
    );

    final current = state.value ?? [];
    state = AsyncData([created, ...current]);
    return created;
  }

  /// Updates an existing prompt in Supabase and updates local state.
  Future<PromptModel> updatePrompt({
    required String id,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    Uint8List? newImageBytes,
    String? imageUrl,
    required bool isPublic,
  }) async {
    final updated = await _repository.updatePrompt(
      id: id,
      title: title,
      content: content,
      category: category,
      tags: tags,
      newImageBytes: newImageBytes,
      imageUrl: imageUrl,
      isPublic: isPublic,
    );

    final current = state.value ?? [];
    state = AsyncData(current.map((p) => p.id == id ? updated : p).toList());
    return updated;
  }

  /// Deletes a prompt from Supabase and removes it from local state.
  Future<void> deletePrompt(String id) async {
    await _repository.deletePrompt(id);

    final current = state.value ?? [];
    state = AsyncData(current.where((p) => p.id != id).toList());
  }

  /// Refreshes the user's prompt list from Supabase.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getUserPrompts());
  }
}
