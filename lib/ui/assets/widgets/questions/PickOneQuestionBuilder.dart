
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class PickOneQuestionBuilder extends QuestionBuilder<PickOneQuestion> {

  const PickOneQuestionBuilder({
    required super.question,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo,
      width: 100,
      height: 100,
      alignment: Alignment.center,
      child: Text(super.question.title),
    );
  }
}