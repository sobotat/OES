
import 'package:oes/src/objects/ApiObject.dart';

enum UserRole {
  admin,
  teacher,
  student,
}

class User extends ApiObject {

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.role = UserRole.student,
  });

  int id;
  String firstName;
  String lastName;
  String username;
  UserRole? role;

  @override
  String toString() {
    return 'User{id: $id, firstName: $firstName, lastName: $lastName, username: $username}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'role': role?.index,
      });
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      role: json['role'] == null ? null : UserRole.values[json['role']],
    );
  }
}