
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/DevicePlatform.dart';

class SignedDevice extends Device {

  SignedDevice({
    required super.name,
    required super.platform,
    required super.isWeb,
    required this.deviceToken,
    required this.lastSignIn
  });

  String deviceToken;
  DateTime lastSignIn;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();
    return super.toMap()
      ..addAll({
        'deviceToken': deviceToken,
        'lastSignIn': lastSignIn.toUtc().toString(),
    });
  }

  factory SignedDevice.fromJson(Map<String, dynamic> json) {
    return SignedDevice(
      name: json['name'],
      platform: DevicePlatform.values.firstWhere((e) => e.index == json['platformId']),
      isWeb: json['isWeb'],
      deviceToken: json['deviceToken'],
      lastSignIn: DateTime.tryParse(json['lastSignIn'])!,
    );
  }
}