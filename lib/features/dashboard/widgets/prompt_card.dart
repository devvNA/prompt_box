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
              flex: 4,
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
              flex: 5,
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
                    const Spacer(),
                    // Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: prompt.tags.take(3).map((tag) {
                        final displayTag = tag.startsWith('#') ? tag : '#$tag';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            displayTag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
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
