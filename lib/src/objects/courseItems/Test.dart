
import 'package:oes/src/objects/courseItems/ExamItem.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionFactory.dart';

class Test extends ExamItem {

  Test({
    required super.id,
    required super.name,
    required super.created,
    required super.createdById,
    required super.scheduled,
    required super.end,
    required super.duration,
    required super.isVisible,
    super.questions = const [],
    required this.maxAttempts,
  }) : super(type: 'test');

  int maxAttempts;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'maxAttempts': maxAttempts,
      });
  }

  factory Test.fromJson(Map<String, dynamic> json) {
    List<Question> questionsList = [];
    for(Map<String, dynamic> questionJson in json['questions'] ?? []) {
      Question? question = QuestionFactory.fromJson(questionJson);
      if (question == null) continue;
      questionsList.add(question);
    }
    
    return Test(
      id: json['id'],
      name: json['name'],
      created: DateTime.tryParse(json['created'])!,
      createdById: json['createdById'],
      isVisible: json['isVisible'],
      scheduled: DateTime.tryParse(json['scheduled'])!,
      end: DateTime.tryParse(json['end'])!,
      duration: json['duration'],
      questions: questionsList,
      maxAttempts: json['maxAttempts'],
    );
  }
}