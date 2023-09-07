import 'package:oes/src/RestApi/ApiObject.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/restApi/UserGateway.dart';

class SignedUser extends ApiObject {
  SignedUser({
    required super.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.token,
  });

  String firstName;
  String lastName;
  String username;
  String? token;
  List<SignedDevice>? _signedDevices;

  Future<List<SignedDevice>> get signedDevices async {
    if (_signedDevices != null) return _signedDevices!;
    _signedDevices = await UserGateway.gateway.getSignedDevices();
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