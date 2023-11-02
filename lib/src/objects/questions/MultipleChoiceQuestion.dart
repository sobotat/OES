
import 'package:oes/src/objects/questions/Question.dart';

abstract class MultipleChoiceQuestion extends Question {

  MultipleChoiceQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.points,
    required this.options,
  }) : super(type: 'multiple-choice');

  List<dynamic> options;

}