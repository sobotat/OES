import 'package:flutter/material.dart';

class PopupDialog extends Dialog {
  const PopupDialog({
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(10),
    required this.child,
    super.key
  });

  final Widget child;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: child
      ),
    );
  }
}
