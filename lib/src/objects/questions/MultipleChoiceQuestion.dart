
import 'package:oes/src/objects/questions/Question.dart';

abstract class MultipleChoiceQuestion extends Question {

  MultipleChoiceQuestion({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.points,
    required this.options,
  });

  List<dynamic> options;

}