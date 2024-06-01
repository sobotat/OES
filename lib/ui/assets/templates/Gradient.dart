import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({
    required this.colors,
    this.child,
    this.borderRadius,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    super.key
  });
  
  final Widget? child;
  final BorderRadius? borderRadius;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppTheme.activeThemeMode,
      builder: (context, child) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5,
              sigmaY: 7,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: colors,
                  begin: begin,
                  end:  end,
                ),
              ),
              child: this.child,
            ),
          ),
        );
      },
    );
  }
}
