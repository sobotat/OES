
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Question.dart';

class DragInQuestion extends Question {

  DragInQuestion({
    required super.id,
    required super.name,
    required super.description,
    required super.options,
    required super.points
  }) : super(type: 'drag-in');

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

}