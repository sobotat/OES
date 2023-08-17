import 'package:oes/src/restApi/DatabaseObject.dart';

enum DevicePlatform {
  android, ios, windows, macos, other
}

class SignedDevice extends DatabaseObject {

  SignedDevice({
    required super.id,
    required this.name,
    required this.platform,
    required this.isWeb,
    required this.lastSignIn,
  });

  String name;
  DevicePlatform platform;
  bool isWeb;
  DateTime lastSignIn;
}