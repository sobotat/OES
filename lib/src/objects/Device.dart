import 'package:oes/src/objects/DevicePlatform.dart';
import 'package:oes/src/restApi/ApiObject.dart';

class Device extends ApiObject {

  Device({
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