import 'package:flutter/material.dart';

class PopupDialog extends Dialog {
  const PopupDialog({
    this.alignment = Alignment.center,
    required this.child,
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
