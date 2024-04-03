
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/MultipleChoiceQuestion.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';

class PickManyQuestion extends MultipleChoiceQuestion {

  PickManyQuestion({
    required super.id,
    required super.name,
    required super.description,
    required super.points,
    required super.options
  }) : super(type: 'pick-many');

  List<int> answers = [];

  factory PickManyQuestion.fromJson(Map<String, dynamic> json) {
    List<dynamic> optionsData = json['options'] ?? [];

    return PickManyQuestion(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      points: json['points'],
      options: optionsData.map((e) => QuestionOption.fromJson(e)).toList(),
    );
  }

  @override
  List<AnswerOption> getAnswerOptions() {
    return answers.map((e) => AnswerOption(questionId: id, id: options[e].id, text: options[e].text)).toList();
  }

  @override
  void setWithAnswerOptions(List<AnswerOption> answers) {
    this.answers.clear();
    for (AnswerOption answer in answers) {
      for (int i = 0; i < options.length; i++) {
        if (options[i].id == answer.id) {
          this.answers.add(i);
          break;
        }
      }
    }
  }

  @override
  int getPointsFromAnswers() {
    int sum = 0;
    for(int index in answers) {
      sum += options[index].points;
    }
    return sum;
  }

}