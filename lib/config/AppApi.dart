import 'package:oes/src/services/LocalStorage.dart';

class AppApi {

  static final AppApi instance = AppApi._();
  AppApi._();

  bool useMuckApi = true;

  Future<void> init() async {
    if (useMuckApi) return;
    useMuckApi = (await LocalStorage.instance.get('useMuck') ?? 'false') as bool;
  }
}