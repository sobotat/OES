
import 'package:flutter/material.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class SmallIconButton extends Button {
  const SmallIconButton({
    super.icon,
    super.toolTip,
    super.toolTipWaitDuration,
    super.onClick,
    super.shouldPopOnClick = false,
    super.iconSize = 18,
    super.textColor,
    super.backgroundColor,
    super.borderRadius,
    this.width = 50,
    super.key
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        child: super.build(context),
      ),
    );
  }
}
