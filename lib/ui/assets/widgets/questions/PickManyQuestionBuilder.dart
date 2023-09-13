
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class PickManyQuestionBuilder extends QuestionBuilder<PickManyQuestion> {

  const PickManyQuestionBuilder({
    required super.question,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan,
      width: 100,
      height: 100,
      alignment: Alignment.center,
      child: Text(super.question.title),
    );
  }
}