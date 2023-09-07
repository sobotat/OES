
import 'package:flutter/material.dart';

class CourseQuizScreen extends StatelessWidget {
  const CourseQuizScreen({
    required this.quizId,
    super.key
  });

  final int quizId;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Quiz $quizId'));
  }
}
