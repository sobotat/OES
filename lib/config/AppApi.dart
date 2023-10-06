import 'package:flutter/material.dart';
import 'package:oes/src/services/LocalStorage.dart';

class AppApi {

  static final AppApi instance = AppApi._();
  AppApi._();

  bool useMockApi = false;

  String mainServerUrl = 'http://oes-main.sobotovi.net:8002';
  String apiServerUrl = 'http://oes-api.sobotovi.net:8001';

  Future<void> init() async {
    String? setting = await LocalStorage.instance.get('useMuck');
    if (setting == null) return;

    try {
      useMockApi = bool.parse(setting);
      debugPrint("Setting loaded [useMock = $useMockApi]");
    } on FormatException {
      debugPrint("Invalid Value on useMock");
      LocalStorage.instance.remove('useMock');
    }
  }
}