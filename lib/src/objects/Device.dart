import 'package:oes/src/objects/DevicePlatform.dart';
import 'package:oes/src/objects/ApiObject.dart';

class Device extends ApiObject {

  Device({
    required super.id,
    required this.name,
    required this.platform,
    required this.isWeb,
    this.lastSignIn,
  });

  String name;
  DevicePlatform platform;
  bool isWeb;
  DateTime? lastSignIn;
}