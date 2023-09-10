
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/courseItems/ScheduledItem.dart';

class Homework extends ScheduledItem {

  Homework({
    required super.id,
    required super.name,
    required super.created,
    required super.createdBy,
    required super.scheduled,
    required super.end,
  });

  //File? file;
}