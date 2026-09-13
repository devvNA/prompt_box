import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum BadgeType {
  image,
  text,
  isPublic,
  isPrivate,
  custom,
}

class PromptBadge extends StatelessWidget {
  final BadgeType type;
  final String? customLabel;
  final Color? customColor;
  final Color? customTextColor;

  const PromptBadge({
    super.key,
    required this.type,
    this.customLabel,
    this.customColor,
    this.customTextColor,
  });

  /// Factory helper that automatically picks IMAGE or TEXT badge based on resultImageUrl
  factory PromptBadge.fromImageUrl(String? imageUrl) {
    return PromptBadge(
      type: (imageUrl != null && imageUrl.isNotEmpty)
          ? BadgeType.image
          : BadgeType.text,
    );
  }

  /// Factory helper for visibility badges
  factory PromptBadge.visibility({required bool isPublic}) {
    return PromptBadge(
      type: isPublic ? BadgeType.isPublic : BadgeType.isPrivate,
    );
  }

  String get _label {
    switch (type) {
      case BadgeType.image:
        return 'IMAGE';
      case BadgeType.text:
        return 'TEXT';
      case BadgeType.isPublic:
        return 'PUBLIC';
      case BadgeType.isPrivate:
        return 'PRIVATE';
      case BadgeType.custom:
        return customLabel ?? '';
    }
  }

  Color get _backgroundColor {
    if (customColor != null) return customColor!;
    switch (type) {
      case BadgeType.image:
        return AppColors.green;
      case BadgeType.text:
        return AppColors.yellow;
      case BadgeType.isPublic:
        return AppColors.purple;
      case BadgeType.isPrivate:
        return AppColors.borderMuted;
      case BadgeType.custom:
        return AppColors.surface;
    }
  }

  Color get _textColor {
    if (customTextColor != null) return customTextColor!;
    switch (type) {
      case BadgeType.isPublic:
        return Colors.white;
      default:
        return AppColors.ink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(
          color: AppColors.ink,
          width: 1.5,
        ),
      ),
      child: Text(
        _label,
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: _textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
