
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';

enum ToastDuration {
  short(duration: 500),
  large(duration: 2000);

  const ToastDuration({
    required this.duration,
  });

  final int duration;
}

class Toast {

  static Future<void> makeToast({
    required String text,
    required BuildContext context,
    ToastDuration duration = ToastDuration.short,
    IconData? icon,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
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
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 50,
              left: 20,
              right: 20,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon != null ? Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(icon,
                        size: 20,
                        color: iconColor,
                      ),
                    ) : Container(height: 0,),
                    Text(text,
                      softWrap: true,
                      style: TextStyle(color: textColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        );
    }).then((value) {
      isActive = false;
    });

    await Future.delayed(Duration(milliseconds: duration.duration));
    if (context.mounted && isActive) {
      context.pop();
    }
    isActive = false;
  }
}