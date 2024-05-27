
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';

class PickOneQuestion extends Question {

  PickOneQuestion({
    required super.id,
    required super.name,
    required super.description,
    required super.points,
    required super.options
  }) : super(type: 'pick-one');

  int? answer;

  factory PickOneQuestion.fromJson(Map<String, dynamic> json) {
    List<dynamic> optionsData = json['options'] ?? [];

    return PickOneQuestion(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      points: json['points'],
      options: optionsData.map((e) => QuestionOption.fromJson(e)).toList(),
    );
  }

  @override
  List<AnswerOption> getAnswerOptions() {
    if (answer == null) return [];
    return [
      AnswerOption(questionId: id, id: options[answer!].id, text: options[answer!].text),
    ];
  }

  @override
  void setWithAnswerOptions(List<AnswerOption> answers) {
    this.answer = null;
    if (answers.isEmpty) return;
    AnswerOption answer = answers.first;
    for(int i = 0; i < options.length; i++) {
      if (options[i].id == answer.id) {
        this.answer = i;
        break;
      }
    }
  }

  @override
  int getPointsFromAnswers() {
    if (answer == null) return 0;
    return options[answer!].points;
  }
}