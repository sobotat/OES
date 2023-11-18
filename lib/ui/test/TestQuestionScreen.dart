
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/widgets/questions/OpenQuestionBuilder.dart';
import 'package:oes/ui/assets/widgets/questions/PickManyQuestionBuilder.dart';
import 'package:oes/ui/assets/widgets/questions/PickOneQuestionBuilder.dart';

class TestQuestionScreen extends StatelessWidget {
  const TestQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Question> questions = [
      PickOneQuestion(
        id: 1,
        title: "Question 1",
        description: "Select the best option to success",
        points: 3,
        options: [
          "Option A", "Option B", "Option C"
        ],
      ),
      PickManyQuestion(
        id: 2,
        title: "Question 2",
        description: "Select the 2 options to success",
        points: 3,
        options: [
          "Option A", "Option B", "Option C"
        ],
      ),
      OpenQuestion(
        id: 3,
        title: "Question 3",
        description: "Write what is best programing lang",
        points: 10,
      ),
    ];

    for(Question q in questions) {
      print(q.toMap().toString());
    }

    return Scaffold(
      appBar: const AppAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return _QuestionBuilder(
              question: questions[index],
            );
          },
        ),
      ),
    );
  }
}

class _QuestionBuilder extends StatelessWidget {
  const _QuestionBuilder({
    required this.question,
    super.key,
  });

  final Question question;

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
