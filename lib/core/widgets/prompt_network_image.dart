import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'web_html_image_stub.dart'
    if (dart.library.js_interop) 'web_html_image_web.dart';

/// Displays a network image with consistent loading, error handling, and a
/// native HTML `<img>` fallback on Flutter Web when CanvasKit decoding/CORS fails.
class PromptNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;
  final Color? errorIconColor;
  final double errorIconSize;
  final Widget? placeholder;
  final Widget? errorWidget;

  const PromptNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderColor,
    this.errorIconColor,
    this.errorIconSize = 28,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = placeholderColor ?? AppColors.borderMuted;

    final Widget defaultPlaceholder = Container(
      width: width,
      height: height,
      color: bgColor,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.muted,
          ),
        ),
      ),
    );

    final Widget defaultError =
        errorWidget ??
        Container(
          width: width,
          height: height,
          color: bgColor,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: errorIconSize,
              color: errorIconColor ?? AppColors.muted,
            ),
          ),
        );

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => placeholder ?? defaultPlaceholder,
      errorWidget: (context, url, error) {
        if (kIsWeb) {
          return SizedBox(
            width: width,
            height: height,
            child: WebHtmlImage(
              imageUrl: url,
              fit: fit,
              borderRadius: borderRadius,
              fallback: defaultError,
            ),
          );
        }
        return defaultError;
      },
    );
  }
}
