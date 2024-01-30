
import 'package:oes/src/objects/questions/Question.dart';

abstract class MultipleChoiceQuestion extends Question {

  MultipleChoiceQuestion({
    required super.id,
    required super.type,
    required super.name,
    required super.description,
    required super.options,
    required super.points,
  });

}