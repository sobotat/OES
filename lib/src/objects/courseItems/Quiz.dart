
import 'package:oes/src/objects/courseItems/ExamItem.dart';
import 'package:oes/src/objects/courseItems/SchedulableItem.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionFactory.dart';

class Quiz extends ExamItem {

  Quiz({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.isVisible,
    required super.scheduled,
    required super.end,
    required super.questions,
  }) : super(type: 'quiz');

  factory Quiz.fromJson(Map<String, dynamic> json) {
    List<Question> questionsList = [];
    for(Map<String, dynamic> questionJson in json['questions'] ?? []) {
      Question? question = QuestionFactory.fromJson(questionJson);
      if (question == null) continue;
      questionsList.add(question);
    }

    return Quiz(
      id: json['id'],
      name: json['name'],
      created: DateTime.tryParse(json['created'])!,
      createdById: json['createdById'],
      isVisible: json['isVisible'],
      scheduled: DateTime.tryParse(json['scheduled'])!,
      end: DateTime.tryParse(json['end'])!,
      questions: questionsList,
    );
  }
}