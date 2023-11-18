
import 'package:oes/src/objects/questions/Question.dart';

class OpenQuestion extends Question {

  OpenQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.points
  }) : super(type: 'open');

  String? answer;

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
    ..addAll({
      'answer': answer,
    });
  }

  factory OpenQuestion.fromJson(Map<String, dynamic> json) {
    return OpenQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points']
    );
  }
}