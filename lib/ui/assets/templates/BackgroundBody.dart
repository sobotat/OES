import 'package:flutter/material.dart';

class BackgroundBody extends StatelessWidget {
  const BackgroundBody({
    this.child,
    super.key,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: width > overflow ? 50 : 5,
      ),
      constraints: const BoxConstraints(
        maxHeight: 600,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(4),
            bottom: Radius.circular(10)
        ),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: child,
    );
  }
}