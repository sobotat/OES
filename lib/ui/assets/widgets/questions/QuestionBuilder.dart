
import 'package:flutter/material.dart';

abstract class QuestionBuilder<Question> extends StatelessWidget {

  const QuestionBuilder({
    required this.question,
    super.key,
  });

  final Question question;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}