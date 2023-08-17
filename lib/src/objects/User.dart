import 'package:oes/src/RestApi/DatabaseObject.dart';
import 'package:oes/src/objects/SignedDevice.dart';

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
  List<SignedDevice>? signedDevices;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;
}