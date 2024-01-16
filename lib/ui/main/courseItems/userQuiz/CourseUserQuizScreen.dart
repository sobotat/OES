
import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseUserQuizScreen extends StatefulWidget {
  const CourseUserQuizScreen({
    required this.courseId,
    required this.quizId,
    super.key
  });

  final int courseId;
  final int quizId;

  @override
  State<CourseUserQuizScreen> createState() => _CourseUserQuizScreenState();
}

class _CourseUserQuizScreenState extends State<CourseUserQuizScreen> {

  UserQuiz? quiz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          if(!AppSecurity.instance.isLoggedIn()) return const Center(child: WidgetLoading(),);
          return FutureBuilder(
            future: CourseGateway.instance.getUserQuiz(AppSecurity.instance.user!, widget.courseId, widget.quizId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              quiz = snapshot.data as UserQuiz;
              return Center(child: Text(quiz!.name));
            },
          );
        },
      ),
    );
  }
}
