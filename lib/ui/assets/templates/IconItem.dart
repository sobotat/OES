
import 'package:flutter/material.dart';

class IconItem extends StatelessWidget {
  const IconItem({
    required this.icon,
    required this.body,
    this.actions = const [],
    this.height = 50,
    this.color = Colors.blueAccent,
    this.onClick,
    this.onHold,
    super.key
  });

  final Widget icon, body;
  final List<Widget> actions;
  final double height;
  final Color color;
  final Function(BuildContext context)? onClick, onHold;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
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
                color: Theme.of(context).colorScheme.primary
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: color,
                      ),
                      alignment: Alignment.center,
                      child: icon,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: body,
                    )
                  ],
                ),
                width > overflow ? Row(
                  children: actions,
                ) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
