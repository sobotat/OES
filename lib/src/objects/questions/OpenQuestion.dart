
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Question.dart';

class OpenQuestion extends Question {

  OpenQuestion({
    required super.id,
    required super.name,
    required super.description,
    required super.points
  }) : super(type: 'open', options: []);

  String answer = "";
  double? similarityPercentage;

  factory OpenQuestion.fromJson(Map<String, dynamic> json) {
    return OpenQuestion(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      points: json['points']
    );
  }

  @override
  List<AnswerOption> getAnswerOptions() {
    return [
      AnswerOption(questionId: id, id: 1, text: answer),
    ];
  }

  @override
  void setWithAnswerOptions(List<AnswerOption> answers) {
    if (answers.isEmpty) return;
    AnswerOption answer = answers.first;
    this.answer = answer.text;
    similarityPercentage = answer.similarityPercentage;
  }

  @override
  int getPointsFromAnswers() {
    return 0;
  }

}