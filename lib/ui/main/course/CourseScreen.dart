
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/CourseGateway.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';
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

      if (context.mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 0,
            ),
            child: width > overflow ? const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      UserInfoButton(
                        width: 150,
                      ),
                      SignOutButton(),
                      ThemeModeButton(),
                    ],
                  ),
                ),
              ],
            ) : const SmallMenu(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          return course != null ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Heading(
                headingText: course!.name,
                actions: width > overflow ? [
                  SizedBox(
                    height: 40,
                    child: _TeachersBuilder(
                      course: course!,
                      axis: Axis.horizontal,
                    ),
                  )
                ] : null,
              ),
              const SizedBox(height: 10,),
              _Description(width: width, overflow: overflow, course: course!),
              (width > overflow && course!.description != '') || width <= overflow ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width > overflow ? 50 : 15,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    const HeadingLine(),
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
                        if (item is Test) {
                          return _TestWidget(
                            course: course!,
                            test: item
                          );
                        } else if (item is Homework) {
                          return _HomeworkWidget(
                            course: course!,
                            homework: item
                          );
                        } else if (item is Quiz) {
                          return _QuizWidget(
                            course: course!,
                            quiz: item,
                          );
                        }
                        return Container();
                      },
                    );
                  },
                ),
              )
            ],
          ) : const Center(
            child: WidgetLoading(),
          );
        },
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
      child: width > overflow ? Align(
        alignment: Alignment.centerLeft,
        child: Container(
          child: course!.description != '' ? SelectableText(
            course!.description,
          ) : Container(),
        ),
      ) : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          course!.description != '' ? SelectableText(
            course!.description,
          ) : Container(),
          course!.description != '' ? const SizedBox(height: 20,) : Container(),
          SizedBox(
            height: 40,
            child: _TeachersBuilder(
              course: course,
              axis: Axis.horizontal,
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

class _TestWidget extends StatefulWidget {
  const _TestWidget({
    required this.course,
    required this.test,
    super.key
  });

  final Course course;
  final Test test;

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {

  Future<void> openPasswordDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => PopupDialog(
        alignment: Alignment.center,
        child: _TestDialog(
          course: widget.course,
          test: widget.test,
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) => openPasswordDialog(context),
      icon: const _IconText(
          text: 'Test',
          backgroundColor: Colors.red
      ),
      body: _ItemBody(
        bodyText: widget.test.name,
      ),
      color: Colors.red,
    );
  }
}

class _TestDialog extends StatefulWidget {
  const _TestDialog({
    required this.course,
    required this.test
  });

  final Course course;
  final Test test;

  @override
  State<_TestDialog> createState() => _TestDialogState();
}

class _TestDialogState extends State<_TestDialog> {

  TextEditingController passwordController = TextEditingController();
  bool enteredWrongPassword = false;
  bool goodPassword = false;
  bool hiddenPassword= true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        goodPassword = checkPassword();
      });
    });
  }

  bool checkPassword() {
    if (widget.test.password == '') return true;
    if (passwordController.text != widget.test.password) {
      return false;
    }
    return true;
  }

  bool startTest(BuildContext context) {
    if (!checkPassword()) {
      debugPrint('Wrong Password to Test');
      return false;
    }

    debugPrint('Open test ${widget.test.name}');
    if (context.mounted) {
      context.goNamed('course-test', pathParameters: {
        'course_id': widget.course.id.toString(),
        'test_id': widget.test.id.toString()}
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 25,
              ),
              child: Text(widget.test.password != '' ? 'Enter Password' : 'Start Test',
                  style: TextStyle(fontSize: 40), textAlign: TextAlign.center),
            ),
            widget.test.password != '' ? SizedBox(
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
                            goodPassword = checkPassword();
                          });
                        },
                        onSubmitted: (value) {
                          if (Platform.isAndroid || Platform.isIOS) return;
                          if (startTest(context)) {
                            context.pop();
                          }else {
                            setState(() {
                              enteredWrongPassword = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5),
                    child: Button(
                      icon: hiddenPassword ? Icons.add_box_outlined : Icons.add_box,
                      maxWidth: 40,
                      onClick: (context) {
                        setState(() {
                          hiddenPassword = !hiddenPassword;
                        });
                      },
                    ),
                  )
                ],
              ),
            ) : Container(width: 0,),
            const SizedBox(height: 15,),
            Button(
              text: 'Start Test',
              onClick: (context) {
                if (startTest(context)) {
                  context.pop();
                }else {
                  setState(() {
                    enteredWrongPassword = true;
                  });
                }
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


class _HomeworkWidget extends StatelessWidget {
  const _HomeworkWidget({
    required this.course,
    required this.homework,
    super.key
  });

  final Course course;
  final Homework homework;

  void openHomework(BuildContext context) {
    debugPrint('Open homework ${homework.name}');
    context.goNamed('course-homework', pathParameters: {
      'course_id': course.id.toString(),
      'homework_id': homework.id.toString()}
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) => openHomework(context),
      icon: const _IconText(
          text: 'Hw',
          backgroundColor: Colors.blueAccent
      ),
      body: _ItemBody(
        bodyText: homework.name,
      ),
      color: Colors.blueAccent,
    );
  }
}

class _QuizWidget extends StatelessWidget {
  const _QuizWidget({
    required this.course,
    required this.quiz,
    super.key
  });

  final Course course;
  final Quiz quiz;

  void openQuiz(BuildContext context) {
    debugPrint('Open quiz ${quiz.name}');
    context.goNamed('course-quiz', pathParameters: {
      'course_id': course.id.toString(),
      'quiz_id': quiz.id.toString()}
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) => openQuiz(context),
      icon: const _IconText(
        text: 'Qz',
        backgroundColor: Colors.greenAccent
      ),
      body: _ItemBody(
        bodyText: quiz.name,
      ),
      color: Colors.greenAccent,
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
    return Tooltip(
      message: '${teacher.firstName} ${teacher.lastName}',
      child: IconItem(
        icon: _IconText(
          text: (teacher.firstName[0] + teacher.lastName[0]).toUpperCase(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        color: Theme.of(context).colorScheme.secondary,
        height: 35,
        mainSize: MainAxisSize.min,
        padding: EdgeInsets.symmetric(horizontal: 2),
      ),
    );
  }
}
