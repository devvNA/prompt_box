import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'brutal_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? iconWidget;

  const EmptyState({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget ??
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
                    border: Border.all(color: AppColors.ink, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.ink,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 32,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.h2.copyWith(letterSpacing: 0.5),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.muted),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppSpacing.xl),
              BrutalButton(
                text: buttonText!,
                variant: BrutalButtonVariant.primary,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
