
import 'package:flutter/material.dart';

class IconItem extends StatelessWidget {
  const IconItem({
    required this.icon,
    this.body,
    this.bodyFlex = 2,
    this.actions = const [],
    this.height = 50,
    this.color = Colors.blueAccent,
    this.backgroundColor,
    this.onClick,
    this.onHold,
    this.mainSize = MainAxisSize.max,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric( horizontal: 10, vertical: 5),
    super.key
  });

  final Widget icon;
  final Widget? body;
  final int bodyFlex;
  final List<Widget> actions;
  final double height;
  final Color color;
  final Color? backgroundColor;
  final Function(BuildContext context)? onClick, onHold;
  final MainAxisSize mainSize;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: padding,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              if (onClick != null) onClick!(context);
            },
            onLongPress: () {
              if (onHold != null) onHold!(context);
            },
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              height: height,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: backgroundColor ?? Theme.of(context).colorScheme.primary
              ),
              child: Row(
                mainAxisAlignment: mainSize == MainAxisSize.max ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                mainAxisSize: mainSize,
                children: [
                  Flexible(
                    flex: bodyFlex,
                    child: Row(
                      mainAxisSize: mainSize,
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 40,
                          height: height,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: color,
                          ),
                          alignment: Alignment.center,
                          child: icon,
                        ),
                        body != null ? Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: body!,
                          ),
                        ) : Container(),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: actions.isEmpty ? 0 : 1,
                    fit: FlexFit.tight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
