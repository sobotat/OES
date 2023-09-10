
import 'package:oes/src/objects/courseItems/ScheduledItem.dart';

abstract class ExamItem extends ScheduledItem {

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