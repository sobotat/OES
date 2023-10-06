
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
    required this.duration,
  });

  int duration;
  List<Question>? _questions;

  Future<List<Question>> get questions async {
    if (_questions != null) return _questions!;
    //TODO: Implement getting questions
    throw UnimplementedError();
  }
}