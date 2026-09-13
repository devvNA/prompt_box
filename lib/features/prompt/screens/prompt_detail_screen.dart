import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/prompt_model.dart';
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

class PromptDetailScreen extends StatefulWidget {
  final PromptModel prompt;

  const PromptDetailScreen({super.key, required this.prompt});

  @override
  State<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends State<PromptDetailScreen> {
  late PromptModel _currentPrompt;
  bool _isExpanded = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentPrompt = widget.prompt;
  }

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: _currentPrompt.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Prompt copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prompt updated successfully!'),
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
            'DELETE PROMPT?',
            style: AppTypography.cardTitle.copyWith(color: AppColors.danger),
          ),
          content: Text(
            'Are you sure you want to delete "${_currentPrompt.title}"? This action cannot be undone.',
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
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(
                  context,
                  PromptDetailResult.delete(_currentPrompt.id),
                ); // Pop detail with delete action
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _formatRelativeTime(DateTime? date) {
    if (date == null) return '2 days ago';
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
          top: !hasImage, // If has image, let image bleed into top status bar
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasImage)
                            _buildHeroSection()
                          else
                            _buildTopNavNoImage(),

                          _buildContentSection(hasImage),
                        ],
                      ),
                    ),
                  ),

                  // Fixed bottom action buttons
                  _buildBottomActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Hero Image
        Container(
          width: double.infinity,
          height: 290,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.ink, width: 2)),
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

              // More Options Button
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavNoImage() {
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
            'Prompt Detail',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),

          // Options Button
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
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(bool hasImage) {
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
                color: const Color(0xFF8BF2FA), // cyan badge from HTML
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

          // Meta Info (Public / Date / Author)
          Row(
            children: [
              Icon(
                _currentPrompt.isPublic ? Icons.public : Icons.lock_outline,
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
              const SizedBox(width: 6),
              const Text(
                '●',
                style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 6),
              Text(
                _formatRelativeTime(_currentPrompt.createdAt),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '●',
                style: TextStyle(fontSize: 8, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 6),
              Text(
                'by ${_currentPrompt.authorName ?? "Devit Nur Azaqi"}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Description / Full Prompt Content
          Container(
            padding: const EdgeInsets.all(14),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayContent,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    height: 1.55,
                    color: AppColors.ink,
                  ),
                ),
                if (isLongContent) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Show less' : 'Read more',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Tags Section
          Text(
            'TAGS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
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
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.ink, width: 1.5),
                ),
                child: Text(
                  cleanTag,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: Row(
        children: [
          // Copy Button
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

          // Edit Button
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

          // Delete Button
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
}
