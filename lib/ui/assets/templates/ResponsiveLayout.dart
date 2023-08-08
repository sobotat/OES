import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobileWidget,
    required this.tabletWidget,
    required this.desktopWidget,
    super.key
  });

  final Widget mobileWidget;
  final Widget tabletWidget;
  final Widget desktopWidget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 550) {
          return mobileWidget;
        } else if (constraints.maxWidth <= 1000) {
          return tabletWidget;
        } else {
          return desktopWidget;
        }
      },
    );
  }
}
