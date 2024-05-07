
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
    _connection = _connect(url);
  }

  String url;
  late HubConnection _connection;
  Map<String, Function(List<dynamic> arguments)> listeners = {};

  Function()? onReconnecting;
  Function()? onReconnected;
  Function()? onClosed;

  HubConnection _connect(String url) {
    HubConnection connection = HubConnectionBuilder()
        .withUrl('${AppApi.instance.apiServerUrl}/$url',
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              return await AppSecurity.instance.getToken();
            },
          )
        )
        .withAutomaticReconnect()
        .build();

    connection.onreconnecting(({error}) {
      if (onReconnecting != null) onReconnecting!();
    });

    connection.onreconnected(({connectionId}) {
      if (onReconnected != null) onReconnected!();
    });

    connection.onclose(({error}) {
      if (onClosed != null) onClosed!();
    },);

    return connection;
  }

  Future<bool> start(Map<String, Function(List<dynamic> arguments)> listeners) async {
    this.listeners = listeners;
    await _connection.start();
    for (MapEntry<String, Function> entry in listeners.entries) {
      _connection.on(entry.key, (arguments) {
        entry.value(arguments ?? []);
      });
    }
    return true;
  }

  Future<void> reset() async {
    _connection = _connect(url);
    await start(listeners);
  }

  Future<void> stop() async {
    await _connection.stop();
  }

  Future<void> send(String message, {List<Object>? arguments}) async {
    await _connection.invoke(message, args: arguments)
      .onError((error, stackTrace) {
        print("⭕ Send $message Failed: $error");
        return null;
    });
  }

  HubConnectionState getState() {
    return _connection.state ?? HubConnectionState.Disconnected;
  }

}