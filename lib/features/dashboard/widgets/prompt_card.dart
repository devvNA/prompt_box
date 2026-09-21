import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../prompt/models/prompt_model.dart';
import '../../prompt/screens/prompt_detail_screen.dart';

class PromptCard extends StatelessWidget {
  final PromptModel prompt;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const PromptCard({
    super.key,
    required this.prompt,
    required this.onUpdate,
    required this.onDelete,
  });

  void _openDetail(BuildContext context) async {
    final result = await Navigator.of(context).push<PromptDetailResult>(
      MaterialPageRoute(builder: (_) => PromptDetailScreen(prompt: prompt)),
    );

    if (result != null && context.mounted) {
      if (result.action == 'delete') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prompt deleted'),
            backgroundColor: AppColors.ink,
            behavior: SnackBarBehavior.floating,
          ),
        );
        onDelete();
      } else if (result.action == 'update' && result.prompt != null) {
        onUpdate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage = prompt.hasImage;
    final promptSnippet = prompt.content.replaceAll(RegExp(r'\s+'), ' ').trim();

    return GestureDetector(
      onTap: () => _openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.ink, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ink,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Abstract Graphic area
            Expanded(
              flex: 7,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isImage ? AppColors.borderMuted : AppColors.yellow,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: isImage
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: prompt.resultImageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _buildAbstractShapes(),
                  ),
                  // Badge Overlapping
                  Positioned(
                    bottom: -10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isImage
                            ? AppColors.green
                            : const Color(0xFF60A5FA), // tag-blue
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                      child: Text(
                        isImage ? 'IMAGE' : 'TXT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              flex: 11,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prompt.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Prompt Snippet
                    if (promptSnippet.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.ink.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1.5, right: 4),
                              child: Icon(
                                Icons.format_quote_rounded,
                                size: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                promptSnippet,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4B5563),
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Tags
                    if (prompt.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          ...prompt.tags.take(2).map((tag) {
                            final displayTag = tag.startsWith('#')
                                ? tag
                                : '#$tag';
                            return Container(
                              constraints: const BoxConstraints(maxWidth: 80),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2F6),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.ink.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                displayTag,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                          if (prompt.tags.length > 2)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.ink.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '+${prompt.tags.length - 2}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const Spacer(),

                    // Footer (Likes & Options)
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF3F4F6)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                size: 14,
                                color: AppColors.ink,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${prompt.likes}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.more_horiz,
                            size: 16,
                            color: AppColors.ink,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbstractShapes() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 10,
          left: 15,
          child: Transform.rotate(
            angle: -0.2,
            child: Container(
              width: 30,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF60A5FA),
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.ink, offset: Offset(2, 2)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 25,
          child: Transform.rotate(
            angle: 0.8,
            child: Container(
              width: 15,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 20,
          child: Transform.rotate(
            angle: 0.8,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.ink, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A reusable shimmer animation widget that applies a gradual shimmering effect
/// over its child widgets using [ShaderMask] and an animated linear gradient.
class ShimmerEffect extends StatefulWidget {
  final Widget child;

  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFD8D2C7),
                Color(0xFFF0ECE1),
                Color(0xFFFFFFFF),
                Color(0xFFF0ECE1),
                Color(0xFFD8D2C7),
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}

/// Visual skeleton loading card matching the Neo-Brutalism card design.
class PromptCardSkeleton extends StatelessWidget {
  final int index;

  const PromptCardSkeleton({super.key, this.index = 0});

  @override
  Widget build(BuildContext context) {
    // Varied widths for titles, snippets, tags, and user profiles per card
    final double titleWidth2;
    final double descWidth;
    final double tagWidth1;
    final double tagWidth2;
    final double authorWidth;

    switch (index % 4) {
      case 1:
        titleWidth2 = 85.0;
        descWidth = 80.0;
        tagWidth1 = 52.0;
        tagWidth2 = 40.0;
        authorWidth = 62.0;
        break;
      case 2:
        titleWidth2 = 60.0;
        descWidth = 70.0;
        tagWidth1 = 42.0;
        tagWidth2 = 34.0;
        authorWidth = 48.0;
        break;
      case 3:
        titleWidth2 = 75.0;
        descWidth = 60.0;
        tagWidth1 = 48.0;
        tagWidth2 = 42.0;
        authorWidth = 56.0;
        break;
      default:
        titleWidth2 = 70.0;
        descWidth = 65.0;
        tagWidth1 = 46.0;
        tagWidth2 = 36.0;
        authorWidth = 50.0;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.ink, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: ShimmerEffect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Konten (Neutral gray block with gradual shimmering effect)
            Expanded(
              flex: 7,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                  ),
                  // Skeleton Badge
                  Positioned(
                    bottom: -10,
                    left: 10,
                    child: Container(
                      width: 44,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.ink, width: 1.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area (Judul, Deskripsi/JSON, Tag, Profil Pengguna)
            Expanded(
              flex: 11,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul (baris skeleton teks tebal horizontal)
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: titleWidth2,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Deskripsi / JSON / Snippet skeleton
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: descWidth,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tag skeleton (baris teks horizontal kecil)
                    Row(
                      children: [
                        Container(
                          width: tagWidth1,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: tagWidth2,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Profil Pengguna (lingkaran kecil skeleton + blok teks pendek berkilau)
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Lingkaran kecil skeleton
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD1D5DB),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Blok teks pendek berkilau untuk nama pengguna
                          Container(
                            width: authorWidth,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
