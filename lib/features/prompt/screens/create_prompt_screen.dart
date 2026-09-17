import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/brutal_button.dart';
import '../../../core/widgets/brutal_input.dart';
import '../models/prompt_model.dart';
import '../providers/prompt_provider.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CreatePromptScreen extends ConsumerStatefulWidget {
  final PromptModel? initialPrompt;
  final bool isRemix;

  const CreatePromptScreen({
    super.key,
    this.initialPrompt,
    this.isRemix = false,
  });

  @override
  ConsumerState<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends ConsumerState<CreatePromptScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagInputController;

  final List<CategoryItem> _categories = [
    CategoryItem(
      name: 'Image Generation',
      icon: Icons.image_outlined,
      color: Color(0xFFF3523B),
    ),
    CategoryItem(
      name: 'Text Generation',
      icon: Icons.edit_note_outlined,
      color: AppColors.yellow,
    ),
    CategoryItem(
      name: 'UI/UX Design',
      icon: Icons.palette_outlined,
      color: AppColors.purple,
    ),
    CategoryItem(
      name: 'Code Assistant',
      icon: Icons.code,
      color: Color(0xFF60A5FA),
    ),
    CategoryItem(
      name: 'Marketing & Copy',
      icon: Icons.campaign_outlined,
      color: AppColors.green,
    ),
    CategoryItem(
      name: 'Other',
      icon: Icons.category_outlined,
      color: Colors.grey.shade600,
    ),
  ];

  late CategoryItem _selectedCategory;
  late List<String> _tags;
  String? _imageUrl;
  Uint8List? _imageBytes;
  bool _isPublic = true;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.initialPrompt;
    _titleController = TextEditingController(text: p?.title ?? '');
    _contentController = TextEditingController(text: p?.content ?? '');
    _tagInputController = TextEditingController();

    _tags = p != null ? List<String>.from(p.tags) : [];

    _imageUrl = p?.resultImageUrl;

    _isPublic = p?.isPublic ?? true;

    final initialCatName = p?.category ?? 'Image Generation';
    _selectedCategory = _categories.firstWhere(
      (c) => c.name.toLowerCase() == initialCatName.toLowerCase(),
      orElse: () => _categories.first,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag(String rawTag) {
    final tag = rawTag.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (picked == null) return;

      // Baca bytes awal
      final rawBytes = await picked.readAsBytes();

      // Kompres ke WebP (aman untuk Android, iOS, dan Web)
      final compressedBytes = await FlutterImageCompress.compressWithList(
        rawBytes,
        minWidth: 1080,
        minHeight: 1080,
        quality: 75, // Kualitas 70-80 adalah sweet spot
        format: CompressFormat.webp,
      );

      if (mounted) {
        setState(() {
          _imageBytes = compressedBytes;
          _imageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Couldn\'t add image: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(
              top: BorderSide(color: AppColors.ink, width: 2),
              left: BorderSide(color: AppColors.ink, width: 2),
              right: BorderSide(color: AppColors.ink, width: 2),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Image source',
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.ink,
                  ),
                  title: Text('Gallery', style: AppTypography.bodyBold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.ink, width: 1.5),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.ink),
                  title: Text('Camera', style: AppTypography.bodyBold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.ink, width: 1.5),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  leading: const Icon(Icons.link, color: AppColors.ink),
                  title: Text('Image URL', style: AppTypography.bodyBold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.ink, width: 1.5),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showImageUrlDialog();
                  },
                ),
                if (_hasImage) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                    title: Text(
                      'Remove image',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: AppColors.danger,
                        width: 1.5,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _imageBytes = null;
                        _imageUrl = null;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageUrlDialog() {
    final urlController = TextEditingController(text: _imageUrl ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.ink, width: 2),
          ),
          title: Text('Image URL', style: AppTypography.cardTitle),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: 'https://example.com/image.jpg',
              hintStyle: AppTypography.caption,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.ink, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTypography.button.copyWith(color: AppColors.muted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: AppColors.ink, width: 2),
                ),
              ),
              onPressed: () {
                final url = urlController.text.trim();
                setState(() {
                  _imageUrl = url.isNotEmpty ? url : null;
                  _imageBytes = null;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(
              top: BorderSide(color: AppColors.ink, width: 2),
              left: BorderSide(color: AppColors.ink, width: 2),
              right: BorderSide(color: AppColors.ink, width: 2),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category',
                      style: AppTypography.cardTitle.copyWith(fontSize: 14),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.ink,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._categories.map((cat) {
                  final isSelected = cat.name == _selectedCategory.name;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.yellow
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.ink,
                            width: isSelected ? 2 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: AppColors.ink,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: cat.color,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                cat.icon,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.ink,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _hasImage =>
      _imageBytes != null ||
      (_imageUrl != null && _imageUrl!.trim().isNotEmpty);

  void _handleSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a title'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add prompt content'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final PromptModel savedPrompt;
      if (widget.initialPrompt == null || widget.isRemix) {
        savedPrompt = await ref
            .read(promptListNotifierProvider.notifier)
            .createPrompt(
              title: title,
              content: content,
              category: _selectedCategory.name,
              tags: List<String>.from(_tags),
              imageBytes: _imageBytes,
              imageUrl: _imageUrl,
              isPublic: _isPublic,
            );
      } else {
        savedPrompt = await ref
            .read(promptListNotifierProvider.notifier)
            .updatePrompt(
              id: widget.initialPrompt!.id,
              title: title,
              content: content,
              category: _selectedCategory.name,
              tags: List<String>.from(_tags),
              newImageBytes: _imageBytes,
              imageUrl: _imageBytes != null ? null : _imageUrl,
              isPublic: _isPublic,
            );
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prompt saved'),
            backgroundColor: AppColors.ink,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.of(context).pop(savedPrompt);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Couldn\'t save prompt: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.sm,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          BrutalInput(
                            label: 'Title',
                            isRequired: true,
                            controller: _titleController,
                            hintText: 'Enter title',
                          ),
                          const SizedBox(height: 20),

                          // Content
                          BrutalInput(
                            label: 'Content',
                            isRequired: true,
                            controller: _contentController,
                            hintText: 'Type your prompt...',
                            minLines: 4,
                            maxLines: 6,
                          ),
                          const SizedBox(height: 20),

                          // Category
                          _buildCategoryField(),
                          const SizedBox(height: 20),

                          // Tags
                          _buildTagsField(),
                          const SizedBox(height: 20),

                          // Result Image
                          _buildResultImageField(),
                          const SizedBox(height: 20),

                          // Visibility
                          _buildVisibilityField(),
                          const SizedBox(height: 24),

                          // Save Button
                          _buildSaveButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.ink,
                size: 24,
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              widget.isRemix
                  ? 'Remix Prompt'
                  : (widget.initialPrompt != null
                      ? 'Edit Prompt'
                      : 'Create New Prompt'),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),

          // Spacer to balance the back button
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CATEGORY',
              style: AppTypography.caption.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTypography.caption.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: _showCategoryPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
              border: AppBorders.standard(color: AppColors.ink),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(2.0, 2.0),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _selectedCategory.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _selectedCategory.icon,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedCategory.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.ink,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TAGS',
          style: AppTypography.caption.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD1D1D1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeTag(tag),
                      child: const Text(
                        '✕',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        // Add a tag input
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
            border: AppBorders.standard(color: const Color(0xFFD1D1D1)),
          ),
          child: TextField(
            controller: _tagInputController,
            textInputAction: TextInputAction.done,
            onSubmitted: _addTag,
            style: AppTypography.body.copyWith(color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'Add a tag...',
              hintStyle: AppTypography.body.copyWith(
                color: const Color(0xFF999999),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add, color: AppColors.ink),
                onPressed: () => _addTag(_tagInputController.text),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RESULT IMAGE',
              style: AppTypography.caption.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(Optional)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.muted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            // Preview column
            Expanded(
              child: _hasImage
                  ? Stack(
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.ink, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: _imageBytes != null
                                ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                : CachedNetworkImage(
                                    imageUrl: _imageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                  ),
                          ),
                        ),
                        // Close / delete button
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageBytes = null;
                                _imageUrl = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.ink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD1D1D1),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'No Image',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Add Image Button
            Expanded(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFA0A0A0),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 28, color: AppColors.ink),
                      const SizedBox(height: 8),
                      Text(
                        'Add Image',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisibilityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VISIBILITY',
          style: AppTypography.caption.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            // Private Button
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isPublic = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: !_isPublic
                        ? AppColors.yellow
                        : const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(8),
                    border: !_isPublic
                        ? Border.all(color: AppColors.ink, width: 2)
                        : Border.all(color: const Color(0xFFD1D1D1), width: 1),
                    boxShadow: !_isPublic
                        ? const [
                            BoxShadow(
                              color: AppColors.ink,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 18, color: AppColors.ink),
                      const SizedBox(width: 8),
                      Text(
                        'Private',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: !_isPublic
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Public Button
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isPublic = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _isPublic
                        ? AppColors.yellow
                        : const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(8),
                    border: _isPublic
                        ? Border.all(color: AppColors.ink, width: 2)
                        : Border.all(color: const Color(0xFFD1D1D1), width: 1),
                    boxShadow: _isPublic
                        ? const [
                            BoxShadow(
                              color: AppColors.ink,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.public, size: 18, color: AppColors.ink),
                      const SizedBox(width: 8),
                      Text(
                        'Public',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: _isPublic
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return BrutalButton(
      text: 'Save Prompt',
      isFullWidth: true,
      isLoading: _isSaving,
      onPressed: _handleSave,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Save Prompt',
            style: AppTypography.button.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
