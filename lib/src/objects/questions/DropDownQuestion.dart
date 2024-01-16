
import 'package:oes/src/objects/questions/Question.dart';

class DropDownQuestion extends Question {

  DropDownQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.options,
    required super.points
  }) : super(type: 'dropdown');

}