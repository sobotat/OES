
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/FillInQuestion.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class FillInQuestionBuilder extends QuestionBuilder<FillInQuestion> {

  const FillInQuestionBuilder({
    required super.question,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      width: 100,
      height: 100,
      alignment: Alignment.center,
      child: Text(super.question.title),
    );
  }
}