import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class PromptTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showHash;
  final Widget? trailing;

  const PromptTag({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.showHash = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final String displayText = showHash && !label.startsWith('#') ? '#$label' : label;

    final Color backgroundColor = isSelected ? AppColors.yellow : AppColors.surface;
    final Color textColor = AppColors.ink;

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(
          color: AppColors.ink,
          width: 1.5,
        ),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(1.5, 1.5),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayText,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: textColor,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }

    return chip;
  }
}
