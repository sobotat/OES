
import 'package:oes/src/RestApi/ObjectDO.dart';

class User extends ObjectDO {
  User({
    required id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.token,
  }) : super(id: id);

  String firstName;
  String lastName;
  String username;
  String? token;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          username == other.username;

  @override
  int get hashCode => username.hashCode;
}