
import 'package:oes/src/objects/questions/Question.dart';

class FillInQuestion extends Question {

  FillInQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.points
  }) : super(type: 'fill-in');

}