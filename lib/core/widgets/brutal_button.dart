import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum BrutalButtonVariant {
  primary,
  accent,
  secondary,
  highlight,
  destructive,
}

class BrutalButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final BrutalButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const BrutalButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.variant = BrutalButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.width,
    this.height,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    if (widget.onPressed == null && !widget.isLoading) {
      return AppColors.borderMuted;
    }
    switch (widget.variant) {
      case BrutalButtonVariant.primary:
        return AppColors.ink;
      case BrutalButtonVariant.accent:
        return AppColors.primary;
      case BrutalButtonVariant.secondary:
        return AppColors.surface;
      case BrutalButtonVariant.highlight:
        return AppColors.yellow;
      case BrutalButtonVariant.destructive:
        return AppColors.danger;
    }
  }

  Color get _textColor {
    if (widget.onPressed == null && !widget.isLoading) {
      return AppColors.muted;
    }
    switch (widget.variant) {
      case BrutalButtonVariant.primary:
      case BrutalButtonVariant.accent:
      case BrutalButtonVariant.destructive:
        return Colors.white;
      case BrutalButtonVariant.secondary:
      case BrutalButtonVariant.highlight:
        return AppColors.ink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;
    final double shadowOffset = _isPressed ? 1.0 : 4.0;
    final double translation = _isPressed ? 3.0 : 0.0;

    Widget content;
    if (widget.isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(_textColor),
        ),
      );
    } else if (widget.child != null) {
      content = widget.child!;
    } else {
      content = Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18, color: _textColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            widget.text!,
            style: AppTypography.button.copyWith(color: _textColor),
          ),
        ],
      );
    }

    Widget button = GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: Transform.translate(
        offset: Offset(translation, translation),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height,
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
            border: AppBorders.standard(color: AppColors.ink),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink,
                offset: Offset(shadowOffset, shadowOffset),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    return button;
  }
}
