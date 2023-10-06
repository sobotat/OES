
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/questions/Question.dart';

class UserQuiz extends CourseItem {

  UserQuiz({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible,
    required this.questions,
  }) : super(type: 'user-quiz');

  List<Question> questions;
}