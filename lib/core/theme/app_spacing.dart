import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Layout specific
  static const double pagePadding = 16.0;
  static const double gridGap = 12.0;

  // Radius
  static const double radiusSmall = 4.0;
  static const double radiusDefault = 6.0;
  static const double radiusLarge = 8.0;

  // Responsive breakpoints
  static const double mobileMax = 430.0;
  static const double tabletMin = 600.0;
  static const double desktopMin = 900.0;

  // Max content width for centering on large screens
  static const double maxContentWidth = 540.0;

  /// Returns adaptive grid column count based on available [width].
  ///
  /// - Mobile (< 600px): 2 columns
  /// - Tablet (600–899px): 3 columns
  /// - Desktop (≥ 900px): 4 columns
  static int gridCrossAxisCount(double width) {
    if (width >= desktopMin) return 4;
    if (width >= tabletMin) return 3;
    return 2;
  }

  /// Returns a responsive thumbnail height for a prompt card of [cardWidth].
  static double promptCardImageHeight(double cardWidth) {
    return (cardWidth * 0.68).clamp(96.0, 156.0);
  }

  /// Builds a responsive grid delegate for prompt card grids so cards adapt to
  /// screen width and system text scaling without overflowing.
  static SliverGridDelegateWithFixedCrossAxisCount promptGridDelegate(
    BuildContext context,
    double maxWidth, {
    double extraContentHeight = 0.0,
  }) {
    final columns = gridCrossAxisCount(maxWidth);
    const spacing = gridGap;
    const totalHorizontalPadding = pagePadding * 2;
    final cardWidth =
        (maxWidth - totalHorizontalPadding - (columns - 1) * spacing) /
        columns;
    final imageHeight = promptCardImageHeight(cardWidth);
    final textScale = MediaQuery.textScalerOf(context).scale(12.0) / 12.0;
    final contentHeight = 76.0 + (110.0 * textScale) + extraContentHeight;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      mainAxisExtent: imageHeight + contentHeight,
    );
  }
}
