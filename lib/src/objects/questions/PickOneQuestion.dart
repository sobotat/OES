
import 'dart:convert';

import 'package:oes/src/objects/questions/MultipleChoiceQuestion.dart';

class PickOneQuestion extends MultipleChoiceQuestion {

  PickOneQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.points,
    required super.options
  }) : super(type: 'pick-one');

  int? answer;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
    ..remove('description')
    ..addAll({
      'answer': answer,
      'description': jsonEncode({
        'description': description,
        'options': options,
      })
    });
  }

  factory PickOneQuestion.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> questionData = jsonDecode(json['description']);

    return PickOneQuestion(
      id: json['id'],
      title: json['title'],
      description: questionData['description'],
      points: json['points'],
      options: questionData['options'],
    );
  }
}