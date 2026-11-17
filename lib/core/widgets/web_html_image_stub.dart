import 'package:flutter/material.dart';

/// Non-web stub for [WebHtmlImage]. Never rendered outside web builds.
class WebHtmlImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget fallback;

  const WebHtmlImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) => fallback;
}
