import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/AppTheme.dart';

class Button extends StatelessWidget {
  const Button({
    this.icon,
    this.text = '',
    this.child,
    this.toolTip,
    this.toolTipWaitDuration,
    this.onClick,
    this.shouldPopOnClick = false,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.iconSize = 18,
    this.textColor,
    this.backgroundColor,
    this.fontFamily,
    this.borderRadius,
    super.key
  });
  
  final IconData? icon;
  final String text;
  final Widget? child;
  final String? toolTip;
  final Duration? toolTipWaitDuration;
  final Function(BuildContext context)? onClick;
  final bool shouldPopOnClick;

  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;
  final double? minHeight;
  final double? iconSize;

  final Color? textColor;
  final Color? backgroundColor;

  final String? fontFamily;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Color activeBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    Color activeTextColor = textColor ?? AppTheme.getActiveTheme().calculateTextColor(activeBackgroundColor, context);

    return Material(
      elevation: 10,
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: InkWell(
        onTap: onClick != null ? () {
          onClick!(context);

          if (shouldPopOnClick) {
            context.pop();
          }
        } : null,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        child: Tooltip(
          message: toolTip ?? '',
          waitDuration: toolTipWaitDuration ?? const Duration(milliseconds: 500),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon != null ? Padding(
                      padding: const EdgeInsets.only(
                        left: 5,
                        right: 5,
                        top: 1,
                      ),
                      child: Icon(
                        icon,
                        color: activeTextColor,
                        size: iconSize,
                      ),
                    ) : Container(),
                    child ?? (
                      text != '' ?
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 15,
                          color: activeTextColor,
                          fontFamily: fontFamily,
                        ),
                      ) : Container()
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
