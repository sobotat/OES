
import 'package:oes/src/restApi/ApiObject.dart';

abstract class CourseItem extends ApiObject {

  CourseItem({
    required super.id,
    required this.name
  });

  String name;

}