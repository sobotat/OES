import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({
    required this.colors,
    this.child,
    this.borderRadius,
    super.key
  });
  
  final Widget? child;
  final BorderRadius? borderRadius;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppTheme.activeThemeMode,
      builder: (context, child) {
        return Stack(
          children: [
            ClipRect(
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
                      begin: Alignment.topLeft,
                      end:  Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            Center(
                child: this.child ?? Container(),
            ),
          ],
        );
      },
    );
  }
}
