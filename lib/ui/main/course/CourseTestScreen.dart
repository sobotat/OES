
import 'package:flutter/material.dart';

class CourseTestScreen extends StatelessWidget {
  const CourseTestScreen({
    required this.testId,
    super.key
  });

  final int testId;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Test $testId'));
  }
}
