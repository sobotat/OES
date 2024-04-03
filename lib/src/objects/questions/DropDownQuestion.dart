
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Question.dart';

class DropDownQuestion extends Question {

  DropDownQuestion({
    required super.id,
    required super.name,
    required super.description,
    required super.options,
    required super.points
  }) : super(type: 'dropdown');

  @override
  List<AnswerOption> getAnswerOptions() {
    // TODO: implement getAnswerOptions
    throw UnimplementedError();
  }

  @override
  void setWithAnswerOptions(List<AnswerOption> answers) {
    // TODO: implement setWithAnswerOptions
    throw UnimplementedError();
  }

  @override
  int getPointsFromAnswers() {
    // TODO: implement getPointsFromAnswers
    throw UnimplementedError();
  }

}