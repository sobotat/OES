
import 'package:oes/src/objects/courseItems/SchedulableItem.dart';

class Homework extends SchedulableItem {

  Homework({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible,
    required super.scheduled,
    required super.end,
  }) : super(type: 'homework');

  //File? file;
}