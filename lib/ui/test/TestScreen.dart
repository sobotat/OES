
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/objects/Achievement.dart';
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

  HubConnection? connection;

  @override
  void initState() {
    super.initState();
    initSignalIr();


    Future.delayed(Duration(seconds: 2), () {
      Achievement a = Achievement.fromJson({'id':'123', 'name': 'name', 'description': '12312', 'unlocked': false});
      AchievementDialog.show(context: context, achievement: a);
    },);
  }

  Future<void> initSignalIr() async {
    connection = HubConnectionBuilder()
        .withUrl('${AppApi.instance.apiServerUrl}/testing', transportType: HttpTransportType.LongPolling)
        .withAutomaticReconnect()
        .build();
    connection!.onreconnecting(({error}) {
      print('Reconnecting');
    });

    connection!.onreconnected(({connectionId}) {
      print('Reconnected');
    });

    connection!.onclose(({error}) {
      if (mounted) {
        setState(() {});
        Toast.makeToast(text: 'Connection Closed', context: context);
      }
      print('Connection Closed');
    },);

    await connection!.start();
    connection!.on('test', (arguments) {
      if (mounted) {
        setState(() {});
        Toast.makeToast(text: 'Message: $arguments', context: context);
      }
      print('Message: $arguments');
    });
    setState(() {});
  }

  Future<void> clicked() async {
    await connection!.invoke('SendMessage').onError((error, stackTrace) {
      if (mounted) {
        setState(() {});
        Toast.makeToast(text: 'Error Invoke: $error', context: context);
      }
      print('Error Invoke: $error');
    });
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
                Toast.makeToast(text: Random().nextInt(1000).toString(), context: context, icon: Icons.add);
                Toast.makeToast(text: Random().nextInt(1000).toString(), context: context, icon: Icons.ac_unit_sharp);
                Toast.makeToast(text: Random().nextInt(1000).toString(), context: context, icon: Icons.account_circle_rounded);
                Toast.makeToast(text: Random().nextInt(1000).toString(), context: context, icon: Icons.adb);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () => clicked(),
                borderRadius: BorderRadius.circular(10),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: connection == null ? Colors.red[300] : connection!.state == HubConnectionState.Connected ? Colors.greenAccent : Colors.orange
                  ),
                  width: 300,
                  height: 500,
                  child: Align(
                    alignment: Alignment.center,
                    child: ListView.builder(
                      itemCount: messages.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Center(child: Text(messages[index]));
                      },
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
