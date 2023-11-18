
import 'dart:convert';

import 'package:oes/src/objects/questions/MultipleChoiceQuestion.dart';

class PickManyQuestion extends MultipleChoiceQuestion {

  PickManyQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.points,
    required super.options
  }) : super(type: 'pick-many');

  List<int> answers = [];

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
    ..addAll({
      'answers': answers,
    });
  }

  factory PickManyQuestion.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> questionData = jsonDecode(json['description']);

    return PickManyQuestion(
      id: json['id'],
      title: json['title'],
      description: questionData['description'],
      points: json['points'],
      options: questionData['options'],
    );
  }
}