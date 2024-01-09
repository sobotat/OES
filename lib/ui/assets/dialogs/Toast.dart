
import 'dart:collection';

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
  static BuildContext? _lastContext;
  static Future? _displayFuture;

  static void makeToast({
    required String text,
    required BuildContext context,
    ToastDuration duration = ToastDuration.short,
    IconData? icon,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    if (!context.mounted) throw Exception('Context is not Mounted');

    _lastContext = context;
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
        if (_lastContext == null || !_lastContext!.mounted) break;
        context = _lastContext!;
        ToastQueueData data = _pendingMessages.removeFirst();

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

        await Future.delayed(Duration(milliseconds: data.duration.duration));
        if (context.mounted && isActive) {
          context.pop();
          isActive = false;
        }

        if (_pendingMessages.isEmpty) {
          _lastContext = null;
          _displayFuture = null;
        }
      }
    });
  }
}