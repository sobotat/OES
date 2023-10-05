
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/ApiObject.dart';

abstract class CourseItem extends ApiObject {

  CourseItem({
    required this.id,
    required this.name,
    required this.created,
    required this.createdBy,
  });

  int id;
  String name;
  DateTime created;
  User createdBy;
}