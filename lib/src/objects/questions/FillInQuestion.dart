
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Question.dart';

class FillInQuestion extends Question {

  FillInQuestion({
    required super.id,
    required super.title,
    required super.description,
    required super.options,
    required super.points
  }) : super(type: 'fill-in');

  @override
  List<AnswerOption> getAnswerOptions() {
    // TODO: implement getAnswerOptions
    throw UnimplementedError();
  }

}