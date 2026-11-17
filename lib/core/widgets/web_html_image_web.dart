import 'dart:async';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Renders an image via a native HTML `<img>` element on Flutter Web.
///
/// Used as a fallback when CanvasKit's `fetch`/CORS image decoder fails
/// (for example on external hosts or storage URLs blocked by CORS in CanvasKit).
class WebHtmlImage extends StatefulWidget {
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
  State<WebHtmlImage> createState() => _WebHtmlImageState();
}

class _WebHtmlImageState extends State<WebHtmlImage> {
  static int _viewCounter = 0;

  late String _viewType;
  bool _hasError = false;
  StreamSubscription<web.Event>? _errorSub;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  @override
  void didUpdateWidget(covariant WebHtmlImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fit != widget.fit ||
        oldWidget.borderRadius != widget.borderRadius) {
      _errorSub?.cancel();
      _hasError = false;
      _registerView();
    }
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    super.dispose();
  }

  void _registerView() {
    _viewType = 'prompt-box-html-img-${_viewCounter++}';
    final imageUrl = widget.imageUrl;
    final objectFit = _mapBoxFit(widget.fit);
    final borderRadius = widget.borderRadius;

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final img = web.HTMLImageElement()
        ..src = imageUrl
        ..alt = ''
        ..referrerPolicy = 'no-referrer'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = objectFit
        ..style.display = 'block'
        ..style.pointerEvents = 'none'
        ..style.userSelect = 'none';

      if (borderRadius != null) {
        img.style.borderTopLeftRadius = '${borderRadius.topLeft.x}px';
        img.style.borderTopRightRadius = '${borderRadius.topRight.x}px';
        img.style.borderBottomLeftRadius = '${borderRadius.bottomLeft.x}px';
        img.style.borderBottomRightRadius = '${borderRadius.bottomRight.x}px';
      }

      _errorSub?.cancel();
      _errorSub = img.onError.listen((_) {
        if (mounted && !_hasError) {
          setState(() => _hasError = true);
        }
      });

      return img;
    });
  }

  String _mapBoxFit(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
      case BoxFit.cover:
      case BoxFit.fitWidth:
      case BoxFit.fitHeight:
        return 'cover';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallback;
    }
    return HtmlElementView(viewType: _viewType);
  }
}
