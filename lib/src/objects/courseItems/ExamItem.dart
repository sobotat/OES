
import 'package:oes/src/objects/courseItems/SchedulableItem.dart';

abstract class ExamItem extends SchedulableItem {

  ExamItem({
    required super.id,
    required super.name,
    required super.created,
    required super.createdBy,
    required super.scheduled,
    required super.end,
    required this.duration,
  });

  int duration;
  //List<QuestionItem> questions;
}