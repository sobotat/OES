
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/DevicePlatform.dart';

class SignedDevice extends Device {

  SignedDevice({
    required super.id,
    required super.name,
    required super.platform,
    required super.isWeb,
    required this.lastSignIn,
    required this.isCurrent,
  });

  DateTime lastSignIn;
  bool isCurrent;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'lastSignIn': lastSignIn.millisecondsSinceEpoch,
        'isCurrent': isCurrent,
    });
  }

  factory SignedDevice.fromJson(Map<String, dynamic> json) {
    return SignedDevice(
      id: json['id'],
      name: json['name'],
      platform: DevicePlatform.values.firstWhere((e) => e.index == json['platform']),
      isWeb: json['isWeb'],
      lastSignIn: DateTime.fromMillisecondsSinceEpoch(json['lastSignIn']),
      isCurrent: json['isCurrent']
    );
  }

}