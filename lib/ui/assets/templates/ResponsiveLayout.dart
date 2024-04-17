import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.small,
    required this.large,
    super.key
  });

  final Widget small;
  final Widget large;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 950) {
          return small;
        } else {
          return large;
        }
      },
    );
  }
}
