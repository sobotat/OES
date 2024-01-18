
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/ui/assets/widgets/questions/OpenQuestionBuilder.dart';
import 'package:oes/ui/assets/widgets/questions/PickManyQuestionBuilder.dart';
import 'package:oes/ui/assets/widgets/questions/PickOneQuestionBuilder.dart';

class QuestionBuilderFactory extends StatelessWidget {
  const QuestionBuilderFactory({
    required this.question,
    this.edit = false,
    super.key,
  });

  final Question question;
  final bool edit;

  @override
  Widget build(BuildContext context) {
    if (question is PickOneQuestion) {
      return PickOneQuestionBuilder(question: question as PickOneQuestion);
    } else if (question is PickManyQuestion) {
      return PickManyQuestionBuilder(question: question as PickManyQuestion);
    } else if (question is OpenQuestion) {
      return OpenQuestionBuilder(question: question as OpenQuestion);
    } else {
      return Text("Question [${question.type}] is Not Supported");
    }
  }
}