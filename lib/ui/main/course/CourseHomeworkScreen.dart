
import 'package:flutter/material.dart';

class CourseHomeworkScreen extends StatelessWidget {
  const CourseHomeworkScreen({
    required this.homeworkId,
    super.key
  });

  final int homeworkId;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Homework $homeworkId'));
  }
}
