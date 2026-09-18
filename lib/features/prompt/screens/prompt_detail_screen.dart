import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/supabase_provider.dart';
import '../../../core/widgets/brutal_button.dart';
import '../../explore/providers/explore_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/prompt_model.dart';
import '../providers/prompt_provider.dart';
import 'create_prompt_screen.dart';

class PromptDetailResult {
  final String action; // 'update' or 'delete'
  final PromptModel? prompt;
  final String? deletedId;

  const PromptDetailResult.update(this.prompt)
    : action = 'update',
      deletedId = null;

  const PromptDetailResult.delete(this.deletedId)
    : action = 'delete',
      prompt = null;
}

class PromptDetailScreen extends ConsumerStatefulWidget {
  final PromptModel prompt;
  final bool? isOwner;

  const PromptDetailScreen({super.key, required this.prompt, this.isOwner});

  @override
  ConsumerState<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends ConsumerState<PromptDetailScreen> {
  late PromptModel _currentPrompt;
  bool _isExpanded = false;
  bool _hasChanges = false;
  late bool _isLiked;
  late bool _isBookmarked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _currentPrompt = widget.prompt;
    _isLiked = widget.prompt.isLiked;
    _isBookmarked = widget.prompt.isBookmarked;
    _likeCount = widget.prompt.likes;

    // Record view and verify like status if viewing community prompt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserId = ref.read(currentUserIdProvider);
      final isOwn =
          widget.isOwner ??
          (currentUserId != null &&
              _currentPrompt.userId != null &&
              _currentPrompt.userId == currentUserId);

      if (!isOwn) {
        ref.read(promptRepositoryProvider).recordView(_currentPrompt.id);

        // Check like status
        ref.read(promptRepositoryProvider).checkIfLiked(_currentPrompt.id).then(
          (liked) {
            if (mounted) {
              setState(() {
                _isLiked = liked;
                _currentPrompt = _currentPrompt.copyWith(isLiked: liked);
              });
              ref
                  .read(explorePromptsNotifierProvider.notifier)
                  .updatePrompt(_currentPrompt);
            }
          },
        );

        // Check bookmark status
        ref
            .read(promptRepositoryProvider)
            .checkIfBookmarked(_currentPrompt.id)
            .then((bookmarked) {
              if (mounted) {
                setState(() {
                  _isBookmarked = bookmarked;
                  _currentPrompt = _currentPrompt.copyWith(
                    isBookmarked: bookmarked,
                  );
                });
                ref
                    .read(explorePromptsNotifierProvider.notifier)
                    .updatePrompt(_currentPrompt);
              }
            });
      }
    });
  }

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: _currentPrompt.content));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'Prompt copied to clipboard',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleToggleLike() async {
    final nextLiked = !_isLiked;
    final nextCount = _likeCount + (nextLiked ? 1 : -1);
    final clampedCount = nextCount < 0 ? 0 : nextCount;

    setState(() {
      _isLiked = nextLiked;
      _likeCount = clampedCount;
      _currentPrompt = _currentPrompt.copyWith(
        isLiked: nextLiked,
        likes: clampedCount,
      );
      _hasChanges = true;
    });

    // Optimistically sync state to explore and prompt list immediately
    ref
        .read(explorePromptsNotifierProvider.notifier)
        .updatePrompt(_currentPrompt);
    ref
        .read(promptListNotifierProvider.notifier)
        .updatePromptInMemory(_currentPrompt);

    try {
      final result = await ref
          .read(promptRepositoryProvider)
          .toggleLike(_currentPrompt.id);
      if (mounted) {
        final serverLiked = result['is_liked'] as bool? ?? _isLiked;
        final serverCount =
            (result['like_count'] as num?)?.toInt() ?? _likeCount;

        setState(() {
          _isLiked = serverLiked;
          _likeCount = serverCount;
          _currentPrompt = _currentPrompt.copyWith(
            isLiked: serverLiked,
            likes: serverCount,
          );
        });

        ref
            .read(explorePromptsNotifierProvider.notifier)
            .updatePrompt(_currentPrompt);
        ref
            .read(promptListNotifierProvider.notifier)
            .updatePromptInMemory(_currentPrompt);
      }
    } catch (_) {}
  }

  void _handleToggleBookmark() async {
    final nextBookmarked = !_isBookmarked;

    setState(() {
      _isBookmarked = nextBookmarked;
      _currentPrompt = _currentPrompt.copyWith(isBookmarked: nextBookmarked);
      _hasChanges = true;
    });

    // Optimistically sync state to explore
    ref
        .read(explorePromptsNotifierProvider.notifier)
        .updatePrompt(_currentPrompt);

    // Update saved collections provider
    if (nextBookmarked) {
      ref
          .read(bookmarkedPromptsNotifierProvider.notifier)
          .addBookmarkLocally(_currentPrompt);
    } else {
      ref
          .read(bookmarkedPromptsNotifierProvider.notifier)
          .removeBookmarkLocally(_currentPrompt.id);
    }

    try {
      final result = await ref
          .read(promptRepositoryProvider)
          .toggleBookmark(_currentPrompt.id);
      if (mounted) {
        setState(() {
          _isBookmarked = result;
          _currentPrompt = _currentPrompt.copyWith(isBookmarked: result);
        });
      }
    } catch (_) {}
  }

  void _handleRemix() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CreatePromptScreen(initialPrompt: _currentPrompt, isRemix: true),
      ),
    );
  }

  Future<void> _handleEdit() async {
    final updated = await Navigator.of(context).push<PromptModel>(
      MaterialPageRoute(
        builder: (_) => CreatePromptScreen(initialPrompt: _currentPrompt),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _currentPrompt = updated;
        _hasChanges = true;
      });
      ref
          .read(explorePromptsNotifierProvider.notifier)
          .updatePrompt(_currentPrompt);
      ref
          .read(promptListNotifierProvider.notifier)
          .updatePromptInMemory(_currentPrompt);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Prompt updated',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.ink,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.ink, width: 2),
          ),
          title: Text(
            'Delete prompt?',
            style: AppTypography.cardTitle.copyWith(color: AppColors.danger),
          ),
          content: Text(
            'Delete "${_currentPrompt.title}"? You can\'t undo this.',
            style: AppTypography.body,
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
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: AppColors.ink, width: 1.5),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx); // Close dialog
                try {
                  await ref
                      .read(promptListNotifierProvider.notifier)
                      .deletePrompt(_currentPrompt.id);
                } catch (_) {}
                if (mounted) {
                  Navigator.pop(
                    context,
                    PromptDetailResult.delete(_currentPrompt.id),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _formatRelativeTime(DateTime? date) {
    if (date == null) return 'Recently';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _onBackPressed() {
    if (_hasChanges) {
      Navigator.of(context).pop(PromptDetailResult.update(_currentPrompt));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final isOwner =
        widget.isOwner ??
        (currentUserId != null &&
            _currentPrompt.userId != null &&
            _currentPrompt.userId == currentUserId);

    final hasImage = _currentPrompt.hasImage;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          top: !hasImage,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasImage)
                            _buildHeroSection(isOwner)
                          else
                            _buildTopNavNoImage(isOwner),

                          _buildContentSection(hasImage, isOwner),
                        ],
                      ),
                    ),
                  ),

                  // Fixed bottom action buttons
                  _buildBottomActionButtons(isOwner),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isOwner) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Hero Image
        GestureDetector(
          onTap: () =>
              _showFullScreenImage(context, _currentPrompt.resultImageUrl!),
          child: Container(
            width: double.infinity,
            height: 290,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.ink, width: 2),
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: _currentPrompt.resultImageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.borderMuted,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.borderMuted,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 40,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Gradient for top icons visibility
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 90,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Top Navigation Over Hero
        Positioned(
          top: 16,
          left: AppSpacing.pagePadding,
          right: AppSpacing.pagePadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              GestureDetector(
                onTap: _onBackPressed,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.ink,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.ink,
                    size: 20,
                  ),
                ),
              ),

              // Right Action Buttons
              if (isOwner)
                PopupMenuButton<String>(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.ink, width: 2),
                  ),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.ink,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ),
                  onSelected: (val) {
                    if (val == 'copy') {
                      _handleCopy();
                    } else if (val == 'edit') {
                      _handleEdit();
                    } else if (val == 'delete') {
                      _handleDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 18, color: AppColors.ink),
                          SizedBox(width: 8),
                          Text('Copy Prompt'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: AppColors.ink),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: AppColors.danger),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _handleToggleLike,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.ink,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: AppColors.danger,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _handleToggleBookmark,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.ink,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: _isBookmarked
                              ? AppColors.green
                              : AppColors.ink,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _handleCopy,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.ink,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.copy,
                          color: AppColors.ink,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavNoImage(bool isOwner) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        12,
        AppSpacing.pagePadding,
        8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: _onBackPressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.ink,
                size: 20,
              ),
            ),
          ),

          Text(
            isOwner ? 'Your Prompt' : 'Community Prompt',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),

          // Options Button
          if (isOwner)
            GestureDetector(
              onTap: _handleEdit,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.ink, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.ink,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.ink,
                  size: 20,
                ),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _handleToggleBookmark,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.ink, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.ink,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: _isBookmarked ? AppColors.green : AppColors.ink,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _handleCopy,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.ink, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.ink,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: AppColors.ink,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection(bool hasImage, bool isOwner) {
    final bool isLongContent = _currentPrompt.content.length > 180;
    final String displayContent = (!isLongContent || _isExpanded)
        ? _currentPrompt.content
        : '${_currentPrompt.content.substring(0, 160)}...';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge (Overlapping if image present)
          Transform.translate(
            offset: Offset(0, hasImage ? -18 : 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8BF2FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                _currentPrompt.category.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),

          // Title
          Transform.translate(
            offset: Offset(0, hasImage ? -6 : 10),
            child: Text(
              _currentPrompt.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Meta Info Row
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              if (isOwner) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _currentPrompt.isPublic
                          ? Icons.public
                          : Icons.lock_outline,
                      size: 15,
                      color: AppColors.ink,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentPrompt.isPublic ? 'Public' : 'Private',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _currentPrompt.isPublic
                            ? const Color(0xFF16A34A)
                            : AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const Text(
                  '●',
                  style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF)),
                ),
                Text(
                  _formatRelativeTime(_currentPrompt.createdAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const Text(
                  '●',
                  style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF)),
                ),
                Text(
                  'by You',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ] else ...[
                // Community meta
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.ink, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.public, size: 13, color: AppColors.ink),
                      const SizedBox(width: 4),
                      Text(
                        'Community Prompt',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '●',
                  style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF)),
                ),
                Text(
                  _formatRelativeTime(_currentPrompt.createdAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const Text(
                  '●',
                  style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 13,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_likeCount likes',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Author Profile Card (When viewing other user's prompt)
          if (!isOwner) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ink, width: 1.5),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          _currentPrompt.authorAvatar ?? 'https://hfjdvymiaipelonyyrsd.supabase.co/storage/v1/object/public/avatar/8e40f83a0f6b6f2e66803af56507b05d.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPrompt.authorName ?? 'Community Creator',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'Community Prompt Engineer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.ink, width: 1.2),
                    ),
                    child: Text(
                      'AUTHOR',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Full Prompt Content Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(2.5, 2.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PROMPT TEXT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.muted,
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleCopy,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.copy,
                            size: 13,
                            color: AppColors.ink,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  displayContent,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    height: 1.55,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isLongContent) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Show less' : 'Read full prompt',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Tags Section
          if (_currentPrompt.tags.isNotEmpty) ...[
            Text(
              'TAGS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentPrompt.tags.map((tag) {
                final cleanTag = tag.startsWith('#') ? tag : '#$tag';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.ink, width: 1.5),
                  ),
                  child: Text(
                    cleanTag,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(bool isOwner) {
    if (isOwner) {
      // Owner view: Copy, Edit, Delete
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Copy',
                icon: Icons.copy,
                backgroundColor: Colors.white,
                textColor: AppColors.ink,
                borderColor: AppColors.ink,
                shadowColor: AppColors.ink,
                onTap: _handleCopy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                backgroundColor: Colors.white,
                textColor: AppColors.ink,
                borderColor: AppColors.ink,
                shadowColor: AppColors.ink,
                onTap: _handleEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: 'Delete',
                icon: Icons.delete_outline,
                backgroundColor: const Color(0xFFD32F2F),
                textColor: Colors.white,
                borderColor: const Color(0xFFD32F2F),
                shadowColor: const Color(0xFF8B0000),
                onTap: _handleDelete,
              ),
            ),
          ],
        ),
      );
    }

    // Community view: Like, Copy Prompt, Remix
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: Row(
        children: [
          // Like Button with count
          GestureDetector(
            onTap: _handleToggleLike,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isLiked ? const Color(0xFFFFECEB) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(2, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _likeCount.toString(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Copy Prompt Button
          Expanded(
            child: BrutalButton(
              text: 'Copy',
              icon: Icons.copy,
              variant: BrutalButtonVariant.secondary,
              onPressed: _handleCopy,
            ),
          ),
          const SizedBox(width: 10),

          // Remix / Use Template Button
          Expanded(
            child: BrutalButton(
              text: 'Remix',
              icon: Icons.auto_awesome,
              variant: BrutalButtonVariant.primary,
              onPressed: _handleRemix,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(2, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(color: Colors.white),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
