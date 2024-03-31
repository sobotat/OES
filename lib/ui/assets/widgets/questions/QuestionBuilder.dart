
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';

abstract class QuestionBuilder<Question> extends StatelessWidget {

  const QuestionBuilder({
    required this.question,
    required this.review,
    super.key,
  });

  final Question question;
  final Review? review;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}

class Review {
  List<AnswerOption> options = [];
}
