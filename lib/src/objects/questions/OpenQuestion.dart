
import 'package:oes/src/objects/questions/Question.dart';

class OpenQuestion extends Question {

  OpenQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.points
  }) : super(type: 'open');

  factory OpenQuestion.fromJson(Map<String, dynamic> json) {
    return OpenQuestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points']
    );
  }
}