
import 'package:oes/src/objects/ApiObject.dart';

class User extends ApiObject {

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username
  });

  int id;
  String firstName;
  String lastName;
  String username;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'id': id,
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