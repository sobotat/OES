
import 'package:oes/src/objects/ApiObject.dart';

class User extends ApiObject {

  User({
    required super.id,
    required this.firstName,
    required this.lastName,
    required this.username
  });

  String firstName;
  String lastName;
  String username;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => super.hashCode ^ id.hashCode;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
      });
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username']
    );
  }
}