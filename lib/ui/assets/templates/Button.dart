import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/ui/assets/templates/MiddleClickListener.dart';
import '../../../config/AppTheme.dart';

class Button extends StatelessWidget {
  const Button({
    this.icon,
    this.text = '',
    this.child,
    this.toolTip,
    this.toolTipWaitDuration,
    this.onClick,
    this.onMiddleClick,
    this.callMiddleClickInNonWeb = false,
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
    this.borderColor,
    this.borderWidth = 2,
    super.key
  });
  
  final IconData? icon;
  final String text;
  final Widget? child;
  final String? toolTip;
  final Duration? toolTipWaitDuration;
  final Function(BuildContext context)? onClick;
  final Function(BuildContext context)? onMiddleClick;
  final bool callMiddleClickInNonWeb;
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
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    Color activeBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    Color activeTextColor = textColor ?? AppTheme.getActiveTheme().calculateTextColor(activeBackgroundColor, context);

    return MiddleClickListener(
      onMiddleClick: (context, isWeb) {
        if(onMiddleClick != null && (isWeb || callMiddleClickInNonWeb)) {
          onMiddleClick!(context);
        }
      },
      child: Material(
        elevation: 4,
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
                  border: borderColor != null ? Border.all(
                    width: borderWidth,
                    color: borderColor!,
                  ) : null,
                  color: activeBackgroundColor,
                ),
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
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            text,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 13,
                              color: activeTextColor,
                              fontFamily: fontFamily,
                            ),
                          ),
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
