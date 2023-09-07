
import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';

class WidgetLoading extends StatelessWidget {
  const WidgetLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(25),
          child: CircularProgressIndicator(
            color: Theme.of(context).extension<AppCustomColors>()!.accent,
          ),
        ),
      ],
    );
  }
}