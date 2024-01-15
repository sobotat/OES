
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:oes/config/AppRouter.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';

enum ToastDuration {
  short(duration: 1000),
  large(duration: 2500);

  const ToastDuration({
    required this.duration,
  });

  final int duration;
}

class ToastQueueData {
  ToastQueueData({
    required this.text,
    required this.duration,
    required this.textColor,
    required this.iconColor,
    this.icon,
  });

  String text;
  IconData? icon;
  ToastDuration duration;
  Color textColor;
  Color iconColor;
}

class Toast {

  static final Queue<ToastQueueData> _pendingMessages = Queue();
  static Future? _displayFuture;

  static void makeToast({
    required String text,
    ToastDuration duration = ToastDuration.short,
    IconData? icon,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {

    _pendingMessages.add(ToastQueueData(
        text: text,
        duration: duration,
        textColor: textColor,
        iconColor: iconColor,
        icon: icon
    ));

    if (_displayFuture != null) return;

    _displayFuture = Future(() async {
      while(_pendingMessages.isNotEmpty) {
        ToastQueueData data = _pendingMessages.removeFirst();

        bool isActive = true;
        BuildContext? currentContext = AppRouter.instance.getCurrentContext();
        if (currentContext != null) {
          showDialog(
              barrierColor: Colors.transparent,
              barrierDismissible: true,
              useSafeArea: true,
              context: currentContext,
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
                              data.icon != null ? Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(data.icon,
                                  size: 20,
                                  color: data.iconColor,
                                ),
                              ) : Container(height: 0,),
                              Text(data.text,
                                softWrap: true,
                                style: TextStyle(color: data.textColor),
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
        } else {
          print("Failed to start Toast because current context is null");
        }

        await Future.delayed(Duration(milliseconds: data.duration.duration));
        if (isActive) AppRouter.instance.router.pop();
        await Future.delayed(const Duration(milliseconds: 200));

        if (_pendingMessages.isEmpty) {
          _displayFuture = null;
        }
      }
    });
  }
}