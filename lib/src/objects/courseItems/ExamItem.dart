
import 'package:oes/src/objects/courseItems/SchedulableItem.dart';
import 'package:oes/src/objects/questions/Question.dart';

abstract class ExamItem extends SchedulableItem {

  ExamItem({
    required super.type,
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.scheduled,
    required super.end,
    required super.isVisible,
    required this.questions,
  });

  List<Question> questions;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'questions': questions.map((e) => e.toMap()).toList(),
    });
  }
}