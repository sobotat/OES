
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/ui/assets/widgets/questions/editor/OpenQuestionEditor.dart';
import 'package:oes/ui/assets/widgets/questions/editor/PickQuestionEditor.dart';

class QuestionEditorFactory extends StatelessWidget {
  const QuestionEditorFactory({
    required this.question,
    required this.onUpdated,
    super.key
  });

  final Question question;
  final Function() onUpdated;

  @override
  Widget build(BuildContext context) {
    switch(question.type) {
      case 'pick-one':
      case 'pick-many':
        return PickQuestionEditor(
            question: question,
            onUpdated: onUpdated
        );
      case 'open':
        return OpenQuestionEditor(
          question: question,
          onUpdated: onUpdated,
        );
      default:
        return const Placeholder();
    }
  }
}