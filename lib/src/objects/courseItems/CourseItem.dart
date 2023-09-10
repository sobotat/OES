
import 'package:oes/src/objects/OtherUser.dart';
import 'package:oes/src/restApi/ApiObject.dart';

abstract class CourseItem extends ApiObject {

  CourseItem({
    required super.id,
    required this.name,
    required this.created,
    required this.createdBy,
  });

  String name;
  DateTime created;
  OtherUser createdBy;
}