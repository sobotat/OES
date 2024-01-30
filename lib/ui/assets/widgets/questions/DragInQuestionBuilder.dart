
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/DragInQuestion.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class DragInQuestionBuilder extends QuestionBuilder<DragInQuestion> {

  const DragInQuestionBuilder({
    required super.question,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      width: 100,
      height: 100,
      alignment: Alignment.center,
      child: Text(super.question.name),
    );
  }
}