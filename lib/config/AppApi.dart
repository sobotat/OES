import 'package:oes/src/services/LocalStorage.dart';

class AppApi {

  static final AppApi instance = AppApi._();
  AppApi._();

  bool useMuckApi = true;

  String mainServerUrl = 'http://oes-main.sobotovi.net:8002';
  String apiServerUrl = 'http://oes-api.sobotovi.net:8001';

  Future<void> init() async {
    useMuckApi = bool.parse(await LocalStorage.instance.get('useMuck') ?? 'false');
  }
}