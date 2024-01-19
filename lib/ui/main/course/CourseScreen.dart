
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'dart:io' show Platform;

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

  bool isInit = false;
  bool isTeacher = false;
  Course? course;
  Function() listenerFunction = () {};

  @override
  void initState() {
    super.initState();
    loadCourse();
    listenerFunction = () {
      loadCourse();
    };
    AppSecurity.instance.addListener(listenerFunction);
  }

  @override
  void dispose() {
    super.dispose();
    AppSecurity.instance.removeListener(listenerFunction);
  }

  Future<void> loadCourse() async {
    var user = AppSecurity.instance.user;
    if (user != null) {
      debugPrint('Loading Course');
      course = await CourseGateway.instance.getCourse(widget.courseID);
      isInit = true;

      if (course != null && AppSecurity.instance.isLoggedIn()) {
          isTeacher = await course!.isTeacherInCourse(AppSecurity.instance.user!);
      }

      if (context.mounted) {
        setState(() {});
      }
    }
  }

  void showCreateDialog(BuildContext context) {
    if (course == null) return;
    showDialog(
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
                            "course_id": course!.id.toString(),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: AppAppBar(
        onRefresh: () {
          loadCourse();
        },
      ),
      body: ListView(
        children: [
          ListenableBuilder(
            listenable: AppSecurity.instance,
            builder: (context, child) {
              if (course != null) {
                return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Heading(
                    headingText: course!.name,
                    actions: isTeacher ? [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Button(
                          icon: Icons.add,
                          toolTip: "Create",
                          maxWidth: 40,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          onClick: (context) {
                            showCreateDialog(context);
                          },
                        ),
                      ),
                    ] : null,
                  ),
                  const SizedBox(height: 10,),
                  _Description(width: width, overflow: overflow, course: course!),
                  course!.description != '' ? Padding(
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
                      future: course!.items,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const WidgetLoading();
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            CourseItem item = snapshot.data![index];
                            if (item.type == 'test') {
                              return _TestWidget(
                                course: course!,
                                item: item,
                                isTeacher: isTeacher,
                              );
                            }
                            return _CourseItemWidget(
                              course: course!,
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
                      future: course!.userQuizzes,
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
              );
              } else {
                return const Center(
                child: WidgetLoading(),
              );
              }
            },
          ),
        ],
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

  Future<void> openPasswordDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => PopupDialog(
        alignment: Alignment.center,
        child: _TestDialog(
          course: course,
          test: item,
        )
      ),
    );
  }

  void edit(BuildContext context) {
    context.goNamed("edit-course-test", pathParameters: {
      "course_id": course.id.toString(),
      "test_id": item.id.toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) {
        if(isTeacher) {
          context.goNamed("info-course-test", pathParameters: {
            'course_id': course.id.toString(),
            'test_id': item.id.toString()
          });
          return;
        }
        openPasswordDialog(context);
      },
      icon: const _IconText(
          text: 'Test',
          backgroundColor: Colors.red
      ),
      body: _ItemBody(
        bodyText: item.name,
      ),
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

class _TestDialog extends StatefulWidget {
  const _TestDialog({
    required this.course,
    required this.test
  });

  final Course course;
  final CourseItem test;

  @override
  State<_TestDialog> createState() => _TestDialogState();
}

class _TestDialogState extends State<_TestDialog> {

  TextEditingController passwordController = TextEditingController();
  bool enteredWrongPassword = false;
  bool goodPassword = false;
  bool hiddenPassword= true;

  Timer? timer;

  Future<bool> checkPassword() async {
    return await CourseGateway.instance.checkTestPassword(widget.course.id, widget.test.id, passwordController.text);
  }

  Future<bool> startTest(BuildContext context) async {
    if (!await checkPassword()) {
      debugPrint('Wrong Password to Test');
      return false;
    }

    debugPrint('Open test ${widget.test.name}');
    if (context.mounted) {
      context.goNamed('course-test', pathParameters: {
        'course_id': widget.course.id.toString(),
        'test_id': widget.test.id.toString(),
        'password': passwordController.text,
      }
      );
    } else {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 500;

    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondary,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 25,
              ),
              child: Text('Enter Password',
                  style: TextStyle(fontSize: 40), textAlign: TextAlign.center),
            ),SizedBox(
              width: width > overflow ? 500 : null,
              child: Row(
                mainAxisSize: width > overflow ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      width: width > overflow ? 450 : null,
                      child: TextField(
                        controller: passwordController,
                        obscureText: hiddenPassword,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        textInputAction: TextInputAction.go,
                        onChanged: (value) {
                          setState(() {
                            enteredWrongPassword = false;
                          });
                          if (timer != null) {
                            timer!.cancel();
                          }

                          timer = Timer(const Duration(seconds: 1), () async {
                            goodPassword = await checkPassword();
                            enteredWrongPassword = !goodPassword;
                            if (mounted) {
                              setState(() {});
                            }
                            timer = null;
                          });
                        },
                        onSubmitted: (value) async {
                          if (Platform.isAndroid || Platform.isIOS) return;
                          if (await startTest(context)) {
                            if (mounted) {
                              context.pop();
                            }
                          }else {
                            enteredWrongPassword = true;
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5),
                    child: Button(
                      icon: hiddenPassword ? Icons.remove_red_eye_outlined : Icons.remove_red_eye_rounded,
                      maxWidth: 40,
                      onClick: (context) {
                        setState(() {
                          hiddenPassword = !hiddenPassword;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Button(
              text: 'Start Test',
              onClick: (context) {
                Future(() async {
                  if (await startTest(context)) {
                    if (mounted) {
                      context.pop();
                    }
                  } else {
                    enteredWrongPassword = true;
                    if (mounted) {
                      setState(() {});
                    }
                  }
                },
                );
              },
              maxWidth: 500,
              backgroundColor: goodPassword ? Colors.green : enteredWrongPassword ? Colors.red : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}


class _CourseItemWidget extends StatelessWidget {
  const _CourseItemWidget({
    required this.course,
    required this.item,
    super.key
  });

  final Course course;
  final CourseItem item;

  void openHomework(BuildContext context) {
    debugPrint('Open ${item.type} ${item.name}');
    context.goNamed('course-${item.type}', pathParameters: {
      'course_id': course.id.toString(),
      '${item.type}_id': item.id.toString()}
    );
  }

  String getIconText() {
    switch(item.type.toLowerCase()) {
      case 'document': return 'F';
      case 'homework': return 'Hw';
      case 'quiz': return 'Qz';
      case 'user-quiz': return 'U-Qz';
    }
    return item.type;
  }

  Color getColor() {
    switch(item.type.toLowerCase()) {
      case 'document': return Colors.lightBlueAccent;
      case 'homework': return Colors.teal;
      case 'quiz': return Colors.greenAccent;
      case 'user-quiz': return Colors.lightGreen;
    }
    return Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) => openHomework(context),
      icon: _IconText(
          text: getIconText(),
          backgroundColor: getColor()
      ),
      body: _ItemBody(
        bodyText: item.name,
      ),
      color: getColor(),
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
