import 'package:flutter/cupertino.dart';
import 'package:oes/src/interfaces/ClearCache.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/UserGateway.dart';

class SignedUser extends User implements ClearCache {
  SignedUser({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.username,
    required this.token,
  });

  String token;
  List<Device>? _signedDevices;

  Future<List<Device>> get signedDevices async {
    if (_signedDevices != null) return _signedDevices!;
    _signedDevices = await UserGateway.instance.getDevices();
    return _signedDevices!;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignedUser &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;

  @override
  void clearCache() {
    _signedDevices = null;
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
    ..addAll({
      'token': token,
    });
  }

  factory SignedUser.fromJson(Map<String, dynamic> json) {
    return SignedUser(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      token: json['token'],
    );
  }
}