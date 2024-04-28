
import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';

class WidgetLoading extends StatelessWidget {
  const WidgetLoading({
    this.progress,
    this.color,
    super.key,
  });

  final double? progress;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(25),
          child: CircularProgressIndicator(
            value: progress,
            color: color ?? Theme.of(context).extension<AppCustomColors>()!.accent,
          ),
        ),
      ],
    );
  }
}