
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MiddleClickListener extends StatelessWidget {
  const MiddleClickListener({
    required this.onMiddleClick,
    required this.child,
    super.key
  });

  final Widget child;
  final Function(BuildContext context, bool isWeb) onMiddleClick;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (event.buttons == kMiddleMouseButton) {
          onMiddleClick(context, kIsWeb);
        }
      },
      child: child,
    );
  }
}
