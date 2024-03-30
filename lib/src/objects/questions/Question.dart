
import 'package:oes/src/objects/ApiObject.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';

abstract class Question extends ApiObject {

  Question({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.options,
    required this.points,
  });

  int id;
  String type;
  String name;
  String description;
  List<QuestionOption> options;
  int points;

  List<AnswerOption> getAnswerOptions();
  void setWithAnswerOptions(List<AnswerOption> answers);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'options': options.map((e) => e.toMap()).toList(),
      'points': points
    };
  }

}