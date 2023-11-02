
import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseQuizScreen extends StatefulWidget {
  const CourseQuizScreen({
    required this.courseId,
    required this.quizId,
    super.key
  });

  final int courseId;
  final int quizId;

  @override
  State<CourseQuizScreen> createState() => _CourseQuizScreenState();
}

class _CourseQuizScreenState extends State<CourseQuizScreen> {

  Quiz? quiz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          return FutureBuilder(
            future: CourseGateway.instance.getCourseItem(widget.courseId, widget.quizId, 'quiz'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              quiz = snapshot.data as Quiz;
              return Center(child: Text(quiz!.name));
            },
          );
        },
      ),
    );
  }
}
