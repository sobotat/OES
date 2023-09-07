
import 'package:oes/src/RestApi/ApiObject.dart';

class OtherUser extends ApiObject {

  OtherUser({
    required super.id,
    required this.firstName,
    required this.lastName,
  });

  String firstName;
  String lastName;
}