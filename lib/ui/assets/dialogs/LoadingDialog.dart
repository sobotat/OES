
import 'package:flutter/material.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    this.progress,
    this.progressColor,
    super.key
  });

  final double? progress;
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    return PopupDialog(
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 10,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.secondary,
          ),
          padding: const EdgeInsets.all(10),
          child: WidgetLoading(
            progress: progress,
            color: progressColor,
          ),
        ),
      ),
    );
  }
}
