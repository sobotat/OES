
import 'dart:convert';

import 'package:oes/src/objects/questions/MultipleChoiceQuestion.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';

class PickOneQuestion extends MultipleChoiceQuestion {

  PickOneQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.points,
    required super.options
  }) : super(type: 'pick-one');

  int? answer;

  factory PickOneQuestion.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> optionsData = json['options'] ?? [];

    return PickOneQuestion(
      id: json['id'],
      title: json['name'],
      description: json['description'],
      points: json['points'],
      options: optionsData.map((e) => QuestionOption.fromJson(e)).toList(),
    );
  }
}