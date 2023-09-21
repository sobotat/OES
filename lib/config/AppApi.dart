import 'package:flutter/material.dart';
import 'package:oes/src/services/LocalStorage.dart';

class AppApi {

  static final AppApi instance = AppApi._();
  AppApi._();

  bool useMuckApi = true;

  String mainServerUrl = 'http://oes-main.sobotovi.net:8002';
  String apiServerUrl = 'http://oes-api.sobotovi.net:8001';

  Future<void> init() async {
    String? setting = await LocalStorage.instance.get('useMuck');
    if (setting == null) return;

    try {
      useMuckApi = bool.parse(setting);
      debugPrint("Setting loaded [useMuck = $useMuckApi]");
    } on FormatException {
      debugPrint("Invalid Value on useMuck");
      LocalStorage.instance.remove('useMuck');
    }
  }
}