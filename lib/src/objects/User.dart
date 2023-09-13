
import 'package:oes/src/RestApi/ApiObject.dart';

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
}