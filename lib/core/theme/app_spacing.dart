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
}
