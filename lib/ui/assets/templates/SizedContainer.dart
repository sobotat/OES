
import 'package:flutter/material.dart';
import 'package:oes/config/AppSettings.dart';

class SizedContainer extends StatelessWidget {
  const SizedContainer({
    this.child,
    super.key
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var largeScreenOverflow = 1800;

    return ConstrainedBox(
      constraints: width > largeScreenOverflow && AppSettings.instance.optimizeUIForLargeScreens ? BoxConstraints(
        maxWidth: largeScreenOverflow as double,
      ) : const BoxConstraints(),
      child: child,
    );
  }
}
