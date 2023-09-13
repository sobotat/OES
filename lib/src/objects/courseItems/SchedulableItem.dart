
import 'package:oes/src/objects/courseItems/CourseItem.dart';

abstract class SchedulableItem extends CourseItem {

  SchedulableItem({
    required super.id,
    required super.name,
    required super.created,
    required super.createdBy,
    required this.scheduled,
    required this.end,
  });

  DateTime scheduled;
  DateTime end;

}