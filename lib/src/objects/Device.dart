import 'package:oes/src/objects/DevicePlatform.dart';
import 'package:oes/src/objects/ApiObject.dart';

class Device extends ApiObject {

  Device({
    required this.name,
    required this.platform,
    required this.isWeb,
  });

  String name;
  DevicePlatform platform;
  bool isWeb;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'name': name,
        'platformId': platform.index,
        'isWeb': isWeb,
      });
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'],
      platform: DevicePlatform.values.firstWhere((e) => e.index == json['platformId']),
      isWeb: json['isWeb'],
    );
  }
}