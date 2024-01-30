
import 'package:oes/src/objects/courseItems/CourseItem.dart';

abstract class SchedulableItem extends CourseItem {

  SchedulableItem({
    required super.type,
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible,
    required this.scheduled,
    required this.end,
  });

  DateTime scheduled;
  DateTime end;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'scheduled': scheduled.toUtc().toString().replaceAll(' ', 'T'),
      'end': end.toUtc().toString().replaceAll(' ', 'T'),
    });
  }

}