
import 'dart:convert';

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
}