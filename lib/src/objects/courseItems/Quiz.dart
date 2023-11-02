
import 'package:oes/src/objects/courseItems/ExamItem.dart';

class Quiz extends ExamItem {

  Quiz({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible,
    required super.scheduled,
    required super.end,
    required super.duration,
    required super.questions,
  }) : super(type: 'quiz');

}