import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppBorders {
  AppBorders._();

  static const double widthDefault = 2.0;
  static const double widthEmphasis = 3.0;
  static const double widthThin = 1.0;

  static Border standard({Color color = AppColors.ink, double width = widthDefault}) {
    return Border.all(color: color, width: width);
  }

  static Border emphasis({Color color = AppColors.ink}) {
    return Border.all(color: color, width: widthEmphasis);
  }

  static Border muted({Color color = AppColors.borderMuted}) {
    return Border.all(color: color, width: widthThin);
  }
}

class AppShadows {
  AppShadows._();

  static const Offset offsetCard = Offset(4.0, 4.0);
  static const Offset offsetCta = Offset(5.0, 5.0);
  static const Offset offsetPressed = Offset(1.0, 1.0);

  static List<BoxShadow> card({Color color = AppColors.ink}) => [
        BoxShadow(
          color: color,
          offset: offsetCard,
          blurRadius: 0,
        ),
      ];

  static List<BoxShadow> cta({Color color = AppColors.ink}) => [
        BoxShadow(
          color: color,
          offset: offsetCta,
          blurRadius: 0,
        ),
      ];

  static List<BoxShadow> pressed({Color color = AppColors.ink}) => [
        BoxShadow(
          color: color,
          offset: offsetPressed,
          blurRadius: 0,
        ),
      ];
}
