import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Functional types for [BrutalSnackbar].
enum BrutalSnackbarType { success, error, warning, info }

extension BrutalSnackbarTypeX on BrutalSnackbarType {
  Color get accentColor {
    switch (this) {
      case BrutalSnackbarType.success:
        return AppColors.green;
      case BrutalSnackbarType.error:
        return AppColors.danger;
      case BrutalSnackbarType.warning:
        return AppColors.yellow;
      case BrutalSnackbarType.info:
        return AppColors.purple;
    }
  }

  String get defaultTag {
    switch (this) {
      case BrutalSnackbarType.success:
        return 'SUCCESS';
      case BrutalSnackbarType.error:
        return 'ERROR';
      case BrutalSnackbarType.warning:
        return 'WARNING';
      case BrutalSnackbarType.info:
        return 'INFO';
    }
  }

  IconData get defaultIcon {
    switch (this) {
      case BrutalSnackbarType.success:
        return Icons.check_circle_outline_rounded;
      case BrutalSnackbarType.error:
        return Icons.error_outline_rounded;
      case BrutalSnackbarType.warning:
        return Icons.warning_amber_rounded;
      case BrutalSnackbarType.info:
        return Icons.info_outline_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case BrutalSnackbarType.success:
      case BrutalSnackbarType.warning:
        return AppColors.ink;
      case BrutalSnackbarType.error:
      case BrutalSnackbarType.info:
        return Colors.white;
    }
  }

  /// Default display duration based on type urgency and readability.
  Duration get defaultDuration {
    if (kIsWeb) {
      return const Duration(seconds: 40);
    }
    // Jika di Android (dan platform non-web lainnya) durasi 5 detik.
    return const Duration(seconds: 4);
  }
}

/// Standalone visual card for Neo-Brutalist snackbars.
class BrutalSnackbarCard extends StatelessWidget {
  final String message;
  final String? title;
  final BrutalSnackbarType type;
  final IconData? icon;
  final VoidCallback? onClose;
  final double? progress;

  const BrutalSnackbarCard({
    super.key,
    required this.message,
    this.title,
    this.type = BrutalSnackbarType.info,
    this.icon,
    this.onClose,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusDefault),
        border: Border.all(
          color: AppColors.ink,
          width: AppBorders.widthEmphasis,
        ),
        boxShadow: AppShadows.card(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusDefault - 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Accent Left Block with Icon
                  Container(
                    width: 52,
                    decoration: BoxDecoration(
                      color: type.accentColor,
                      border: const Border(
                        right: BorderSide(
                          color: AppColors.ink,
                          width: AppBorders.widthEmphasis,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon ?? type.defaultIcon,
                      size: 24,
                      color: type.iconColor,
                    ),
                  ),

                  // Message and Title Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tag Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: type.accentColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSmall,
                              ),
                              border: Border.all(
                                color: AppColors.ink,
                                width: AppBorders.widthThin,
                              ),
                            ),
                            child: Text(
                              (title ?? type.defaultTag).toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Message Text
                          Text(
                            message,
                            style: AppTypography.bodyBold.copyWith(
                              fontSize: 13,
                              height: 1.3,
                              color: AppColors.ink,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tactile Close Button
                  if (onClose != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: _BrutalCloseButton(onTap: onClose!),
                      ),
                    ),
                ],
              ),
            ),

            // Animated Countdown Progress Bar
            if (progress != null)
              Container(
                height: 3.5,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.ink, width: 1.2),
                  ),
                  color: Color(0x1F111111),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress!.clamp(0.0, 1.0),
                  child: Container(color: type.accentColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tactile close button with scale-on-press feedback.
class _BrutalCloseButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BrutalCloseButton({required this.onTap});

  @override
  State<_BrutalCloseButton> createState() => _BrutalCloseButtonState();
}

class _BrutalCloseButtonState extends State<_BrutalCloseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.scale(
        scale: _isPressed ? 0.94 : 1.0,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            border: Border.all(
              color: AppColors.ink,
              width: AppBorders.widthThin,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    const BoxShadow(
                      color: AppColors.ink,
                      offset: Offset(1.5, 1.5),
                      blurRadius: 0,
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.close_rounded,
            size: 15,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// Reusable top overlay manager for [BrutalSnackbar].
class BrutalSnackbar {
  BrutalSnackbar._();

  static OverlayEntry? _activeEntry;
  static _BrutalSnackbarOverlayState? _activeState;

  /// Shows a Neo-Brutalist snackbar sliding down from the TOP of the screen.
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    BrutalSnackbarType type = BrutalSnackbarType.info,
    IconData? icon,
    Duration? duration,
  }) {
    // Immediately remove any existing snackbar to prevent nesting/overlapping bugs
    // on rapid multiple clicks.
    if (_activeEntry != null && _activeEntry!.mounted) {
      _activeEntry!.remove();
    }
    _activeEntry = null;
    _activeState = null;

    final effectiveDuration = duration ?? type.defaultDuration;
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _BrutalSnackbarOverlay(
        key: UniqueKey(),
        message: message,
        title: title,
        type: type,
        icon: icon,
        duration: effectiveDuration,
        onDismissed: () {
          if (_activeEntry == entry) {
            if (_activeEntry!.mounted) {
              _activeEntry!.remove();
            }
            _activeEntry = null;
            _activeState = null;
          }
        },
        onStateCreated: (state) {
          _activeState = state;
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  /// Dismisses the current active snackbar with an exit animation.
  static void hide() {
    if (_activeState != null) {
      _activeState!.dismiss();
    } else if (_activeEntry != null) {
      if (_activeEntry!.mounted) {
        _activeEntry!.remove();
      }
      _activeEntry = null;
      _activeState = null;
    }
  }

  /// Convenience helper for success messages.
  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) => show(
    context,
    message: message,
    title: title,
    type: BrutalSnackbarType.success,
    duration: duration,
  );

  /// Convenience helper for error messages.
  static void showError(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) => show(
    context,
    message: message,
    title: title,
    type: BrutalSnackbarType.error,
    duration: duration,
  );

  /// Convenience helper for warning messages.
  static void showWarning(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) => show(
    context,
    message: message,
    title: title,
    type: BrutalSnackbarType.warning,
    duration: duration,
  );

  /// Convenience helper for info messages.
  static void showInfo(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) => show(
    context,
    message: message,
    title: title,
    type: BrutalSnackbarType.info,
    duration: duration,
  );
}

class _BrutalSnackbarOverlay extends StatefulWidget {
  final String message;
  final String? title;
  final BrutalSnackbarType type;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismissed;
  final ValueChanged<_BrutalSnackbarOverlayState> onStateCreated;

  const _BrutalSnackbarOverlay({
    super.key,
    required this.message,
    this.title,
    required this.type,
    this.icon,
    required this.duration,
    required this.onDismissed,
    required this.onStateCreated,
  });

  @override
  State<_BrutalSnackbarOverlay> createState() => _BrutalSnackbarOverlayState();
}

class _BrutalSnackbarOverlayState extends State<_BrutalSnackbarOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _progressController;
  bool _isDismissing = false;
  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();
    widget.onStateCreated(this);

    // Slide animation (enter from top)
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, -1.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    // Progress animation for countdown bar (starts fully full at 1.0)
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    );

    // Slide in first, then start countdown timer once fully visible
    _slideController.forward().then((_) {
      if (mounted && !_isDismissing) {
        _progressController.reverse();
      }
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        dismiss();
      }
    });
  }

  void _pauseTimer() {
    if (!_isDismissing && _progressController.isAnimating) {
      _progressController.stop();
    }
  }

  void _resumeTimer() {
    if (!_isDismissing &&
        _slideController.isCompleted &&
        !_progressController.isAnimating &&
        _progressController.value > 0.0) {
      _progressController.reverse();
    }
  }

  void dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _progressController.stop();
    _slideController.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            left: AppSpacing.pagePadding,
            right: AppSpacing.pagePadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxContentWidth,
              ),
              child: SlideTransition(
                position: _slideAnimation,
                child: MouseRegion(
                  onEnter: (_) => _pauseTimer(),
                  onExit: (_) => _resumeTimer(),
                  child: GestureDetector(
                    onVerticalDragStart: (_) {
                      _dragDistance = 0.0;
                      _pauseTimer();
                    },
                    onVerticalDragUpdate: (details) {
                      _dragDistance += details.primaryDelta ?? 0;
                      // Require intentional upward swipe of at least 32 logical pixels
                      if (_dragDistance < -32) {
                        dismiss();
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity! < -300) {
                        dismiss();
                      } else {
                        _resumeTimer();
                      }
                    },
                    onVerticalDragCancel: () => _resumeTimer(),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return BrutalSnackbarCard(
                          message: widget.message,
                          title: widget.title,
                          type: widget.type,
                          icon: widget.icon,
                          onClose: dismiss,
                          progress: _progressController.value,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
