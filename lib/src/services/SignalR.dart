
import 'package:flutter/material.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalR {

  SignalR(this.url, {
    this.onReconnecting,
    this.onReconnected,
    this.onClosed,
  }) {
    connection = connect(url);
  }

  String url;
  late HubConnection connection;
  Map<String, Function(List<Object?>? arguments)> listeners = {};

  Function()? onReconnecting;
  Function()? onReconnected;
  Function()? onClosed;

  HubConnection connect(String url) {
    HubConnection connection = HubConnectionBuilder()
        .withUrl('${AppApi.instance.apiServerUrl}/$url',
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              return AppSecurity.instance.user!.token;
            },
          )
        )
        .withAutomaticReconnect()
        .build();

    connection.onreconnecting(({error}) {
      if (onReconnecting != null) onReconnecting!();
      Toast.makeToast(text: "Reconnecting", duration: ToastDuration.short, icon: Icons.connect_without_contact_rounded);
    });

    connection.onreconnected(({connectionId}) {
      if (onReconnected != null) onReconnected!();
      Toast.makeSuccessToast(text: "Reconnected");
    });

    connection.onclose(({error}) {
      if (onClosed != null) onClosed!();
    },);

    return connection;
  }

  Future<bool> start(Map<String, Function(List<Object?>? arguments)> listeners) async {
    this.listeners = listeners;
    await connection.start();
    for (MapEntry<String, Function> entry in listeners.entries) {
      connection.on(entry.key, (arguments) {
        entry.value(arguments);
      });
    }
    return true;
  }

  Future<void> reset() async {
    connection = connect(url);
    await start(listeners);
  }

  Future<void> stop() async {
    await connection.stop();
  }

  Future<void> send(String message, {List<Object>? arguments}) async {
    await connection.invoke(message, args: arguments);
  }

  HubConnectionState getState() {
    return connection.state ?? HubConnectionState.Disconnected;
  }

}