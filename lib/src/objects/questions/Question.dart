
import 'package:oes/src/objects/ApiObject.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';

abstract class Question extends ApiObject {

  Question({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.options,
    required this.points,
  });

  int id;
  String type;
  String title;
  String description;
  List<QuestionOption> options;
  int points;

  List<AnswerOption> getAnswerOptions();

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'options': options.map((e) => e.toMap()).toList(),
      'points': points
    };
  }
}