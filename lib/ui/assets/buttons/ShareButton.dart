import 'package:flutter/material.dart';
import 'package:oes/src/restApi/interface/ShareGateway.dart';
import 'package:oes/ui/assets/dialogs/ShareDialog.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    required this.courseId,
    required this.itemId,
    required this.gateway,
    super.key
  });

  final int courseId;
  final int itemId;
  final ShareGateway gateway;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Button(
        icon: Icons.share_outlined,
        toolTip: "Share",
        maxWidth: 40,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onClick: (context) {
          showDialog(
            context: context,
            builder: (context) => ShareDialog(
              courseId: courseId,
              itemId: itemId,
              gateway: gateway,
            ),
          );
        },
      ),
    );
  }
}