
import 'package:oes/src/objects/ApiObject.dart';

class User extends ApiObject {

  User({
    required this.firstName,
    required this.lastName,
    required this.username
  });

  String firstName;
  String lastName;
  String username;

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
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username']
    );
  }
}