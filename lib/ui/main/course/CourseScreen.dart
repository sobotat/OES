
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/RefreshWidget.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({
    required this.courseID,
    super.key
  });

  final int courseID;

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {

  GlobalKey<RefreshWidgetState> refreshKey = GlobalKey<RefreshWidgetState>();

  Future<bool> getIsTeacher(Course course) async {
    if (AppSecurity.instance.isLoggedIn()) {
      return await course.isTeacherInCourse(AppSecurity.instance.user!);
    }
    return false;
  }

  Future<void> showCreateDialog(BuildContext context, Course course) async {
    refreshKey.currentState?.disableRefreshOnPop();
    await showDialog(
      context: context,
      builder: (context) {
        return PopupDialog(
          alignment: Alignment.center,
          child: Container(
            width: 490,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.background,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Create",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _BigIconButton(
                        icon: Icons.text_increase,
                        text: "Test",
                        onClick: () {
                          print("Create Test");
                          context.goNamed("create-course-test", pathParameters: {
                            "course_id": course.id.toString(),
                          });
                          context.pop();
                        },
                      ),
                      _BigIconButton(
                        icon: Icons.quiz,
                        text: "Quiz",
                        onClick: () {
                          print("Create Quiz");
                          context.pop();
                        },
                      ),
                      _BigIconButton(
                        icon: Icons.home_work,
                        text: "Homework",
                        onClick: () {
                          print("Create Homework");
                          context.pop();
                        },
                      ),
                      _BigIconButton(
                        icon: Icons.file_open,
                        text: "Notes",
                        onClick: () {
                          print("Create Notes");
                          context.goNamed("create-course-note", pathParameters: {
                            "course_id": course.id.toString(),
                          });
                          context.pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );

    refreshKey.currentState?.enableRefreshOnPop();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: AppAppBar(
        onRefresh: () {
          refreshKey.currentState?.refresh();
        },
      ),
      body: ListenableBuilder(
          listenable: AppSecurity.instance,
        builder: (context, x) {
          if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
          return RefreshWidget(
            key: refreshKey,
            onRefreshed: () {
              setState(() {});
            },
            child: FutureBuilder(
                future: CourseGateway.instance.getCourse(widget.courseID),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    Toast.makeErrorToast(text: "Failed to load Course");
                    context.pop();
                  }
                  if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                  Course course = snapshot.data!;
                  return FutureBuilder(
                    future: getIsTeacher(course),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        Toast.makeErrorToast(text: "Failed to load IsTeacher in Course");
                      }
                      if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                      bool isTeacher = snapshot.data!;
                      return ListView(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Heading(
                                headingText: course.name,
                                actions: isTeacher ? [
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Button(
                                      icon: Icons.add,
                                      toolTip: "Create",
                                      maxWidth: 40,
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      onClick: (context) {
                                        showCreateDialog(context, course);
                                      },
                                    ),
                                  ),
                                ] : null,
                              ),
                              const SizedBox(height: 10,),
                              _Description(width: width, overflow: overflow, course: course),
                              course.description != '' ? Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width > overflow ? 50 : 15,
                                ),
                                child: const Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    HeadingLine(),
                                  ],
                                ),
                              ) : Container(),
                              BackgroundBody(
                                child: FutureBuilder<List<CourseItem>>(
                                  future: CourseGateway.instance.getCourseItems(course.id),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return const WidgetLoading();
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        CourseItem item = snapshot.data![index];
                                        if (item.type == 'test') {
                                          return _TestWidget(
                                            course: course,
                                            item: item,
                                            isTeacher: isTeacher,
                                          );
                                        }
                                        return _CourseItemWidget(
                                            isTeacher: isTeacher,
                                            course: course,
                                            item: item
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const Heading(headingText: 'My Quizzes'),
                              BackgroundBody(
                                child: FutureBuilder(
                                  future: course.userQuizzes,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return const WidgetLoading();
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        // return _UserQuizWidget(
                                        //   course: course!,
                                        //   quiz: snapshot.data![index],
                                        // );
                                        return Container();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  );
                },
            ),
          );
        }
      ),
    );
  }
}

class _BigIconButton extends StatelessWidget {

  const _BigIconButton({
    required this.icon,
    required this.text,
    required this.onClick,
    super.key,
  });

  final IconData icon;
  final String text;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onClick,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.secondary,
          ),
          width: 150,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                size: 60,
              ),
              Text(text),
            ]
          ),
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.course,
    required this.width,
    required this.overflow,
    super.key,
  });

  final Course course;
  final double width;
  final int overflow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width > overflow ? 50 : 15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          course.description != '' ? Align(
            alignment: width > overflow ? Alignment.centerLeft : Alignment.center,
            child: SelectableText(
              course.description,
            ),
          ) : Container(),
          course.description != '' ? const SizedBox(height: 20,) : Container(),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: width > overflow ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                width > overflow ? const Text("Teachers:  ", style: TextStyle(fontWeight: FontWeight.bold)) : Container(),
                _TeachersBuilder(
                  course: course,
                  axis: Axis.horizontal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeachersBuilder extends StatelessWidget {
  const _TeachersBuilder({
    required this.course,
    required this.axis,
    super.key,
  });

  final Course course;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: course.teachers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.length,
          scrollDirection: axis,
          itemBuilder: (context, index) {
            return TeacherWidget(
                teacher: snapshot.data![index],
            );
          },
        );
      }
    );
  }
}


class _TestWidget extends StatelessWidget {
  const _TestWidget({
    required this.course,
    required this.item,
    required this.isTeacher,
  });

  final Course course;
  final CourseItem item;
  final bool isTeacher;

  void edit(BuildContext context) {
    if (!isTeacher) return;
    context.goNamed("edit-course-test", pathParameters: {
      "course_id": course.id.toString(),
      "test_id": item.id.toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) {
        // if(isTeacher) {
        //   context.goNamed("info-course-test", pathParameters: {
        //     'course_id': course.id.toString(),
        //     'test_id': item.id.toString()
        //   });
        //   return;
        // }
        // openPasswordDialog(context);
        context.goNamed("course-test", pathParameters: {
          'course_id': course.id.toString(),
          'test_id': item.id.toString(),
        });
      },
      icon: const _IconText(
          text: 'Test',
          backgroundColor: Colors.red
      ),
      body: _ItemBody(
        bodyText: item.name,
      ),
      onHold: isTeacher ? (context) {
        edit(context);
      } : null,
      color: Colors.red,
      actions: [
         isTeacher ? Padding(
          padding: const EdgeInsets.all(5),
          child: Button(
            text: "",
            toolTip: "Edit",
            iconSize: 18,
            maxWidth: 40,
            icon: Icons.edit,
            onClick: (context) {
              edit(context);
            },
          ),
        ) : Container(),
      ],
    );
  }
}


class _CourseItemWidget extends StatelessWidget {
  const _CourseItemWidget({
    required this.isTeacher,
    required this.course,
    required this.item,
    super.key
  });

  final bool isTeacher;
  final Course course;
  final CourseItem item;

  void open(BuildContext context) {
    debugPrint('Open ${item.type} ${item.name}');
    context.goNamed('course-${item.type}', pathParameters: {
      'course_id': course.id.toString(),
      '${item.type}_id': item.id.toString()}
    );
  }

  void edit(BuildContext context) {
    if(!isTeacher) return;
    debugPrint('Edit ${item.type} ${item.name}');
    context.goNamed('edit-course-${item.type}', pathParameters: {
      'course_id': course.id.toString(),
      '${item.type}_id': item.id.toString()}
    );
  }

  String getIconText() {
    switch(item.type.toLowerCase()) {
      case 'note': return 'Note';
      case 'homework': return 'Hw';
      case 'quiz': return 'Qz';
      case 'user-quiz': return 'U-Qz';
    }
    return item.type;
  }

  Color getColor() {
    switch(item.type.toLowerCase()) {
      case 'note': return Colors.deepPurple.shade400;
      case 'homework': return Colors.teal;
      case 'quiz': return Colors.greenAccent;
      case 'user-quiz': return Colors.lightGreen;
    }
    return Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) => open(context),
      icon: _IconText(
          text: getIconText(),
          backgroundColor: getColor()
      ),
      body: _ItemBody(
        bodyText: item.name,
      ),
      color: getColor(),
      onHold: isTeacher ? (context) {
        edit(context);
      } : null,
      actions: [
        isTeacher ? Padding(
          padding: const EdgeInsets.all(5),
          child: Button(
            text: "",
            toolTip: "Edit",
            iconSize: 18,
            maxWidth: 40,
            icon: Icons.edit,
            onClick: (context) {
              edit(context);
            },
          ),
        ) : Container(),
      ],
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({
    required this.text,
    required this.backgroundColor,
    super.key
  });

  final String text;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.displaySmall!.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.getActiveTheme().calculateTextColor(backgroundColor, context)
      ),
    );
  }
}

class _ItemBody extends StatelessWidget {
  const _ItemBody({
    required this.bodyText,
    this.padding = const EdgeInsets.all(0),
    super.key
  });

  final String bodyText;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SelectableText(
        bodyText,
        maxLines: 1,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontSize: 16,
        ),
      ),
    );
  }
}

class TeacherWidget extends StatelessWidget {
  const TeacherWidget({
    required this.teacher,
    super.key
  });

  final User teacher;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary,
      ),
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Center(
        child: Text("${teacher.firstName} ${teacher.lastName}",
        )
      )
    );
  }
}
