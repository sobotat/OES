
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/questions/Question.dart';

class UserQuiz extends CourseItem {

  UserQuiz({
    required super.id,
    required super.name,
    required super.created,
    required super.createdBy,
    required this.questions,
  });

  List<Question> questions;
}