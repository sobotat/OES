import 'package:oes/src/RestApi/ApiObject.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/UserGateway.dart';

class SignedUser extends User {
  SignedUser({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.username,
    this.token,
  });

  String? token;
  List<Device>? _signedDevices;

  Future<List<Device>> get signedDevices async {
    if (_signedDevices != null) return _signedDevices!;
    _signedDevices = await UserGateway.instance.getSignedDevices();
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
}