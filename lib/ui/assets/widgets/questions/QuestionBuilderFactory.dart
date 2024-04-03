
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/Review.dart';
import 'package:oes/ui/assets/widgets/questions/OpenQuestionBuilder.dart';
import 'package:oes/ui/assets/widgets/questions/PickManyQuestionBuilder.dart';
import 'package:oes/ui/assets/widgets/questions/PickOneQuestionBuilder.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class QuestionBuilderFactory extends StatelessWidget {
  const QuestionBuilderFactory({
    required this.question,
    this.review,
    super.key,
  });

  final Question question;
  final Review? review;

  @override
  Widget build(BuildContext context) {
    if (question is PickOneQuestion) {
      return PickOneQuestionBuilder(
        question: question as PickOneQuestion,
        review: review,
      );
    } else if (question is PickManyQuestion) {
      return PickManyQuestionBuilder(
        question: question as PickManyQuestion,
        review: review,
      );
    } else if (question is OpenQuestion) {
      return OpenQuestionBuilder(
        question: question as OpenQuestion,
        review: review,
      );
    } else {
      return Text("Question [${question.type}] is Not Supported");
    }
  }
}