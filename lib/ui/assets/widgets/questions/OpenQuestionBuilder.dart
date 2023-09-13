
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class OpenQuestionBuilder extends QuestionBuilder<OpenQuestion> {

  const OpenQuestionBuilder({
    required super.question,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: 100,
      height: 100,
      alignment: Alignment.center,
      child: Text(super.question.title),
    );
  }
}