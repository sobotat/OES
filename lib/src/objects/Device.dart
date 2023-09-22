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

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'name': name,
        'platform': platform.name,
        'isWeb': isWeb,
        'lastSignIn': lastSignIn
      });
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      platform: DevicePlatform.values.firstWhere((e) => e.toString() == 'DevicePlatform.${json['platform']}'),
      isWeb: json['isWeb'],
      lastSignIn: json['lastSignIn']
    );
  }
}