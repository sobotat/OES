
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/DropDownQuestion.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class DropDownQuestionBuilder extends QuestionBuilder<DropDownQuestion> {

  const DropDownQuestionBuilder({
    required super.question,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      width: 100,
      height: 100,
      alignment: Alignment.center,
      child: Text(super.question.title),
    );
  }
}