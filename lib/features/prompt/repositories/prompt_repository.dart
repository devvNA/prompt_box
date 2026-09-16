import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/constants.dart';
import '../../../core/utils/uuid_generator.dart';
import '../models/prompt_model.dart';

class PromptRepository {
  final SupabaseClient _supabase;

  PromptRepository(this._supabase);

  static const Map<String, String> defaultCategoryColors = {
    'Image Generation': '#F3523B',
    'Text Generation': '#FDE047',
    'UI/UX Design': '#C084FC',
    'Code Assistant': '#60A5FA',
    'Marketing & Copy': '#4ADE80',
    'Other': '#757575',
  };

  /// Ensures a category exists for the given user, creating it if necessary.
  Future<String> _ensureCategoryId(String ownerId, String categoryName) async {
    final existing = await _supabase
        .from('categories')
        .select('id')
        .eq('owner_id', ownerId)
        .eq('name', categoryName)
        .maybeSingle();

    if (existing != null && existing['id'] != null) {
      return existing['id'] as String;
    }

    final color = defaultCategoryColors[categoryName] ?? '#6366F1';
    final inserted = await _supabase
        .from('categories')
        .insert({'owner_id': ownerId, 'name': categoryName, 'color': color})
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  /// Synchronizes tags for a given prompt in [tags] and [prompt_tags] tables.
  Future<void> _syncPromptTags(String promptId, List<String> tags) async {
    // Delete existing relation links for this prompt
    await _supabase.from('prompt_tags').delete().eq('prompt_id', promptId);

    for (final rawTag in tags) {
      final cleanTag = rawTag.trim().replaceAll('#', '').toLowerCase();
      if (cleanTag.isEmpty) continue;

      // Find or insert into tags table
      final existing = await _supabase
          .from('tags')
          .select('id')
          .eq('name', cleanTag)
          .maybeSingle();

      String tagId;
      if (existing != null && existing['id'] != null) {
        tagId = existing['id'] as String;
      } else {
        final inserted = await _supabase
            .from('tags')
            .insert({'name': cleanTag})
            .select('id')
            .single();
        tagId = inserted['id'] as String;
      }

      // Link prompt with tag
      await _supabase.from('prompt_tags').insert({
        'prompt_id': promptId,
        'tag_id': tagId,
      });
    }
  }

  /// Uploads image bytes to Supabase Storage bucket 'prompt-results' and returns accessible URL.
  Future<String> _uploadImage({
    required String ownerId,
    required String promptId,
    required Uint8List imageBytes,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    // Path follows RLS convention: {owner_id}/{prompt_id}/{filename}
    final path = '$ownerId/$promptId/$fileName';

    await _supabase.storage
        .from(AppConstants.storageBucketPromptResults)
        .uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    try {
      // Use signed URL for private bucket access (5-year expiry)
      return await _supabase.storage
          .from(AppConstants.storageBucketPromptResults)
          .createSignedUrl(path, 60 * 60 * 24 * 365 * 5);
    } catch (_) {
      // Fallback to public URL
      return _supabase.storage
          .from(AppConstants.storageBucketPromptResults)
          .getPublicUrl(path);
    }
  }

  /// Creates a new prompt in Supabase Postgres and Storage.
  Future<PromptModel> createPrompt({
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    Uint8List? imageBytes,
    String? imageUrl,
    required bool isPublic,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception(
        'User is not authenticated. Please log in to create a prompt.',
      );
    }

    final promptId = UuidGenerator.v4();
    String? finalImageUrl = imageUrl;

    if (imageBytes != null && imageBytes.isNotEmpty) {
      finalImageUrl = await _uploadImage(
        ownerId: user.id,
        promptId: promptId,
        imageBytes: imageBytes,
      );
    }

    final categoryId = await _ensureCategoryId(user.id, category);

    final row = await _supabase
        .from(AppConstants.tablePrompts)
        .insert({
          'id': promptId,
          'owner_id': user.id,
          'category_id': categoryId,
          'title': title,
          'content': content,
          'is_public': isPublic,
          'result_image_url': ?finalImageUrl,
        })
        .select('*, categories(name, color), profiles(username)')
        .single();

    if (tags.isNotEmpty) {
      await _syncPromptTags(promptId, tags);
    }

    return PromptModel.fromMap(row).copyWith(tags: tags);
  }

  /// Updates an existing prompt in Supabase.
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
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception(
        'User is not authenticated. Please log in to edit a prompt.',
      );
    }

    final categoryId = await _ensureCategoryId(user.id, category);
    String? finalImageUrl = imageUrl;

    if (newImageBytes != null && newImageBytes.isNotEmpty) {
      finalImageUrl = await _uploadImage(
        ownerId: user.id,
        promptId: id,
        imageBytes: newImageBytes,
      );
    }

    final updateData = <String, dynamic>{
      'title': title,
      'content': content,
      'category_id': categoryId,
      'is_public': isPublic,
      'result_image_url': finalImageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final row = await _supabase
        .from(AppConstants.tablePrompts)
        .update(updateData)
        .eq('id', id)
        .eq('owner_id', user.id)
        .select('*, categories(name, color), profiles(username)')
        .single();

    await _syncPromptTags(id, tags);

    return PromptModel.fromMap(row).copyWith(tags: tags);
  }

  /// Deletes a prompt and its related resources.
  Future<void> deletePrompt(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    await _supabase
        .from(AppConstants.tablePrompts)
        .delete()
        .eq('id', id)
        .eq('owner_id', user.id);
  }

  /// Fetches all prompts owned by the currently authenticated user.
  Future<List<PromptModel>> getUserPrompts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return [];
    }

    final rows = await _supabase
        .from(AppConstants.tablePrompts)
        .select(
          '*, categories(name, color), prompt_tags(tags(name)), profiles(username)',
        )
        .eq('owner_id', user.id)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((r) => PromptModel.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single prompt by its ID.
  Future<PromptModel?> getPromptById(String id) async {
    final row = await _supabase
        .from(AppConstants.tablePrompts)
        .select(
          '*, categories(name, color), prompt_tags(tags(name)), profiles(username)',
        )
        .eq('id', id)
        .maybeSingle();

    if (row == null) return null;
    return PromptModel.fromMap(row);
  }
}
