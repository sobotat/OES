import 'package:flutter/material.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class RefreshButton extends StatelessWidget {
  const RefreshButton({
    required this.onRefresh,
    this.padding,
    super.key
  });

  final EdgeInsets? padding;
  final Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        child: Button(
          icon: Icons.refresh,
          iconSize: 18,
          backgroundColor: Theme.of(context).colorScheme.primary,
          text: '',
          toolTip: 'Refresh',
          onClick: (context) {
            onRefresh();
          },
        ),
      ),
    );
  }
}
