import 'package:flutter/material.dart';
import '../../../config/AppTheme.dart';

class Button extends StatelessWidget {
  const Button({
    required this.text,
    required this.onClick,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.textColor,
    this.backgroundColor,
    this.fontFamily,
    this.borderRadius,
    super.key
  });

  final String text;
  final Function(BuildContext context) onClick;

  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;
  final double? minHeight;

  final Color? textColor;
  final Color? backgroundColor;

  final String? fontFamily;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Color activeBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () { onClick(context); },
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: Container(
        constraints: BoxConstraints(
          minWidth: minWidth ?? maxWidth ?? 200,
          minHeight: minHeight ?? maxHeight ?? 35,
          maxWidth: maxWidth ?? 200,
          maxHeight: maxHeight ?? 35,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(10),
            color: activeBackgroundColor,
          ),
          child: OverflowBox(
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: textColor ?? AppTheme.getActiveTheme().calculateTextColor(activeBackgroundColor),
                fontFamily: fontFamily,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
