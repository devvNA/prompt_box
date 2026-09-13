import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class BrutalCard extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool animateOnPress;

  const BrutalCard({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.ink,
    this.borderWidth = AppBorders.widthDefault,
    this.borderRadius = AppSpacing.radiusDefault,
    this.shadowOffset = AppShadows.offsetCard,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.animateOnPress = true,
  });

  @override
  State<BrutalCard> createState() => _BrutalCardState();
}

class _BrutalCardState extends State<BrutalCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool canInteract = widget.onTap != null;
    final bool shouldAnimate = canInteract && widget.animateOnPress;

    final double currentShadow = shouldAnimate && _isPressed ? 1.0 : widget.shadowOffset.dx;
    final double translation = shouldAnimate && _isPressed ? widget.shadowOffset.dx - 1.0 : 0.0;

    Widget card = Transform.translate(
      offset: Offset(translation, translation),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.borderColor,
              offset: Offset(currentShadow, currentShadow),
              blurRadius: 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );

    if (canInteract) {
      return GestureDetector(
        onTapDown: (_) {
          if (shouldAnimate) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (shouldAnimate) setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () {
          if (shouldAnimate) setState(() => _isPressed = false);
        },
        child: card,
      );
    }

    return card;
  }
}
