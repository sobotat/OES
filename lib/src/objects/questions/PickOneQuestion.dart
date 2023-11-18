
import 'dart:convert';

import 'package:oes/src/objects/questions/MultipleChoiceQuestion.dart';

class PickOneQuestion extends MultipleChoiceQuestion {

  PickOneQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.points,
    required super.options
  });

  int? answer;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
    ..addAll({
        'answer': answer,
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