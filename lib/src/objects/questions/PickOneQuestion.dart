
import 'dart:convert';

import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/MultipleChoiceQuestion.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';

class PickOneQuestion extends MultipleChoiceQuestion {

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
}