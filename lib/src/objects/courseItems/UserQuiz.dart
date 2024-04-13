
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionFactory.dart';

class UserQuiz extends CourseItem {

  UserQuiz({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible,
    required this.questions,
  }) : super(type: 'userquiz');

  List<Question> questions;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'questions': questions.map((e) => e.toMap()).toList(),
    });
  }

  factory UserQuiz.fromJson(Map<String, dynamic> json) {
    List<Question> questionsList = [];
    for(Map<String, dynamic> questionJson in json['questions'] ?? []) {
      Question? question = QuestionFactory.fromJson(questionJson);
      if (question == null) continue;
      questionsList.add(question);
    }

    return UserQuiz(
      id: json['id'],
      name: json['name'],
      created: DateTime.tryParse(json['created'])!,
      createdById: json['createdById'],
      isVisible: json['isVisible'],
      questions: questionsList,
    );
  }
}