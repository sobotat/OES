
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Achievement.dart';
import 'package:oes/src/services/SignalR.dart';
import 'package:oes/ui/assets/dialogs/AchievementDialog.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AnimatedProgressIndicator.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});
  
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  double value = .5;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, _) {
          if(!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                ),
                child: const SizedBox(
                  width: 400,
                  height: 400,
                  child: Center(child: Text("I'm a big button.")),
                ),
              ),
              ElevatedButton(
                onPressed: () async {

                  GestureBinding.instance
                      .handlePointerEvent(const PointerDownEvent(
                    position: Offset(200, 300),
                  ));
                  await Future.delayed(const Duration(milliseconds: 500));
                  GestureBinding.instance
                      .handlePointerEvent(const PointerUpEvent(
                    position: Offset(200, 300),
                  ));
                },
                child: const Text('Simulate Click'),
              ),
              AnimatedProgressIndicator(
                value: value,
                startColor: Colors.blue.shade700,
                endColor: Theme.of(context).extension<AppCustomColors>()!.accent,
              ),
              Button(
                onClick: (c) {
                  value = Random().nextDouble();
                  setState(() {});
                },
                text: 'Set Progress',
              ),
            ],
          );
        }
      ),
    );
  }
}

