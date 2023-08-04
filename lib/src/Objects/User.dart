
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
}