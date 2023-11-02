
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/objects/Achievement.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';

class AchievementDialog {

  static Future<void> show({
    required BuildContext context,
    required Achievement achievement,
  }) async {
    if (!context.mounted) return Future.error(Exception('Context is not Mounted'));
    bool isActive = true;

    showDialog(
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        useSafeArea: true,
        context: context,
        builder: (context) {
          return PopupDialog(
              alignment: Alignment.topRight,
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 75,
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    ),
                    height: 75,
                    width: 250,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10
                    ),
                    child: Text(achievement.name),
                  ),
                ),
              )
          );
        }).then((value) {
      isActive = false;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (context.mounted && isActive) {
      context.pop();
    }
    isActive = false;
  }
}
