import 'package:flutter/material.dart';
import 'package:oes/config/AppSettings.dart';
import 'package:oes/ui/assets/templates/SizedContainer.dart';

class BackgroundBody extends StatelessWidget {
  const BackgroundBody({
    this.child,
    this.padding,
    super.key,
  });

  final Widget? child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;
    var largeScreenOverflow = 1800;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        margin: padding ?? EdgeInsets.symmetric(
          horizontal: width > overflow ? 50 : 15,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
              bottom: Radius.circular(10)
          ),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: SizedContainer(
          child: child,
        ),
      ),
    );
  }
}