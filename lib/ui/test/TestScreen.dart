
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Achievement.dart';
import 'package:oes/src/services/SignalR.dart';
import 'package:oes/ui/assets/dialogs/AchievementDialog.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});
  
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  List<String> messages = [];
  late SignalR signalR;

  @override
  void initState() {
    super.initState();
    signalR = SignalR("signalr/quiz",
      onReconnected: () {
        setState(() {},);
      },
      onReconnecting: () {
        setState(() {},);
      },
      onClosed: () {
        setState(() {},);
      },
    );
    init();

    Future.delayed(const Duration(seconds: 2), () {
      Achievement a = Achievement.fromJson({'id':'123', 'name': 'name', 'description': '12312', 'unlocked': false});
      AchievementDialog.show(context: context, achievement: a);
    },);
  }

  Future<void> init() async {
    await signalR.start({
      "JoinGroupCallback": (arguments) {
        Toast.makeToast(text: 'JoinGroupCallback: $arguments');
        setState(() {});
      },
      "RemoveFromGroupCallback": (arguments) {
        Toast.makeToast(text: 'RemoveFromGroupCallback: $arguments');
        setState(() {});
      }
    });
    setState(() {});
  }



  Future<void> clicked() async {
    await signalR.send("JoinGroup");
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: Center(
        child: Column(
          children: [
            Button(
              text: "Make Toast",
              backgroundColor: Colors.red.shade700,
              onClick: (context) {
                Toast.makeToast(text: Random().nextInt(1000).toString(), icon: Icons.add);
                Toast.makeToast(text: Random().nextInt(1000).toString(), icon: Icons.ac_unit_sharp);
                Toast.makeToast(text: Random().nextInt(1000).toString(), icon: Icons.account_circle_rounded);
                Toast.makeToast(text: Random().nextInt(1000).toString(), icon: Icons.adb);
              },
            ),
            Button(
              text: "Join",
              onClick: (context) async {
                await signalR.send("JoinGroup", arguments: [AppSecurity.instance.user!.id, "ABC"]);
              },
              backgroundColor: signalR.getState() == HubConnectionState.Connected ? Colors.green : Colors.red,
            ),
            Button(
              text: "Disconnect",
              onClick: (context) async {
                await signalR.send("RemoveFromGroup", arguments: [AppSecurity.instance.user!.id, "ABC"]);
              },
            )
          ],
        ),
      ),
    );
  }
}
