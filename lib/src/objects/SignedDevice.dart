import 'package:oes/src/objects/DevicePlatform.dart';
import 'package:oes/src/restApi/DatabaseObject.dart';

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