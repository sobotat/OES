
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/SizedContainer.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseQuizInfoScreen extends StatelessWidget {
  const CourseQuizInfoScreen({
    required this.courseId,
    required this.quizId,
    super.key
  });

  final int courseId;
  final int quizId;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading());
          return FutureBuilder(
            future: Future(() async {
              Course? course = await CourseGateway.instance.get(courseId);
              if (course == null) return false;
              return await course.isTeacherInCourse(AppSecurity.instance.user as User);
            }),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              bool isTeacher = snapshot.data!;

              return FutureBuilder(
                future: Future(() async {
                  var x = await CourseGateway.instance.getItems(courseId);
                  return x.where((element) => element.id == quizId).singleOrNull;
                } as FutureOr Function()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: WidgetLoading());
                  CourseItem quiz = snapshot.data;
                  return ListView(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Heading(
                            headingText: quiz.name,
                            actions: [
                              FutureBuilder<bool>(
                                  future: Future(() async {
                                    Course? course = await CourseGateway.instance.get(courseId);
                                    return await course?.isTeacherInCourse(AppSecurity.instance.user!) ?? false;
                                  }),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return Container();
                                    bool isTeacher = snapshot.data!;
                                    if (!isTeacher) return Container();
                                    return Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Button(
                                        icon: Icons.edit,
                                        toolTip: "Edit",
                                        maxWidth: 40,
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        onClick: (context) {
                                          context.goNamed('edit-course-quiz', pathParameters: {
                                            'course_id': courseId.toString(),
                                            'quiz_id': quizId.toString(),
                                          });
                                        },
                                      ),
                                    );
                                  }
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width > overflow ? 50 : 15,
                              vertical: 20,
                            ),
                            child: SizedContainer(
                              child: Button(
                                maxWidth: double.infinity,
                                maxHeight: 100,
                                backgroundColor: Colors.green.shade700,
                                text: isTeacher ? "Start Quiz" : "Join Quiz",
                                onClick: (context) {
                                  context.goNamed("start-course-quiz", pathParameters: {
                                    "course_id": courseId.toString(),
                                    "quiz_id": quizId.toString(),
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                },
              );
            }
          );
        },
      ),
    );
  }
}
