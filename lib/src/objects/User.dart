import 'package:oes/src/RestApi/DatabaseObject.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/src/restApi/UserGateway.dart';

class User extends DatabaseObject {
  User({
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

  Future<List<SignedDevice>> getSignedDevices() async {
    return await UserGateway.gateway.getSignedDevices();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;
}