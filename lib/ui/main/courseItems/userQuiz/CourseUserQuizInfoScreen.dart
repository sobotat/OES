
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/SharePermission.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/courseItems/UserQuizShareGateway.dart';
import 'package:oes/ui/assets/buttons/ShareButton.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseUserQuizInfoScreen extends StatelessWidget {
  const CourseUserQuizInfoScreen({
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
              var x = await CourseGateway.instance.getItems(courseId);
              return x.where((element) => element.id == quizId).singleOrNull;
            } as FutureOr Function()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              CourseItem quiz = snapshot.data;
              return ListView(
                children: [
                  Heading(
                    headingText: quiz.name,
                    actions: [
                      ShareButton(
                        courseId: courseId,
                        itemId: quizId,
                        gateway: UserQuizShareGateway.instance,
                      ),
                      FutureBuilder(
                        future: UserQuizShareGateway.instance.getPermission(quiz.id, AppSecurity.instance.user!.id),
                        builder: (context, snapshot) {
                          SharePermission permission = snapshot.data ?? SharePermission.viewer;
                          return permission == SharePermission.editor ? Padding(
                            padding: const EdgeInsets.all(5),
                            child: Button(
                              icon: Icons.edit,
                              toolTip: "Edit",
                              maxWidth: 40,
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              onClick: (context) {
                                context.goNamed('edit-course-userquiz', pathParameters: {
                                  'course_id': courseId.toString(),
                                  'userquiz_id': quizId.toString(),
                                });
                              },
                            ),
                          ) : Container();
                        }
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width > overflow ? 50 : 15,
                      vertical: 20,
                    ),
                    child: Button(
                      maxWidth: double.infinity,
                      maxHeight: 100,
                      backgroundColor: Colors.green.shade700,
                      text: "Start UserQuiz",
                      onClick: (context) {
                        context.goNamed("start-course-userquiz", pathParameters: {
                          "course_id": courseId.toString(),
                          "userquiz_id": quizId.toString(),
                        });
                      },
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
