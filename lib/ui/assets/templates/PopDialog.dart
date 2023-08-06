
import 'package:flutter/material.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class PopupDialog extends Dialog {
  const PopupDialog({
    required this.child,
    required this.alignment,
    super.key
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Align(
        alignment: alignment,
        child: child
      ),
    );
  }
}
