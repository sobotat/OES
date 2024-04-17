

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseTestInfoScreen extends StatelessWidget {
  const CourseTestInfoScreen({
    required this.courseId,
    required this.testId,
    super.key
  });

  final int courseId;
  final int testId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
          return FutureBuilder(
            future: TestGateway.instance.getInfo(testId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Toast.makeErrorToast(text: "Failed to get Info about Test -> ${snapshot.error}", duration: ToastDuration.large);
                context.pop();
              }
              if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
              TestInfo info = snapshot.data!;
              int remainsAttempts = info.maxAttempts - info.attempts.length;

              return FutureBuilder(
                future: Future(() async {
                  Course? course = await CourseGateway.instance.getCourse(courseId);
                  if (course == null) return false;
                  return await course.isTeacherInCourse(AppSecurity.instance.user as User);
                }),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                  bool isTeacher = snapshot.data!;

                  if (isTeacher) {
                    return FutureBuilder(
                      future: CourseGateway.instance.getCourseStudents(courseId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                        List<User> users = snapshot.data!;
                        return _TeacherBody(
                          courseId: courseId,
                          testId: testId,
                          info: info,
                          users: users,
                        );
                      }
                    );
                  }
                  return _StudentBody(
                    courseId: courseId,
                    testId: testId,
                    remainsAttempts: remainsAttempts,
                    info: info,
                  );
                }
              );
            }
          );
        },
      ),
    );
  }
}

class _TeacherBody extends StatelessWidget {
  const _TeacherBody({
    required this.courseId,
    required this.testId,
    required this.info,
    required this.users,
    super.key
  });

  final int courseId;
  final int testId;
  final TestInfo info;
  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Heading(
          headingText: "Info",
          actions: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.print,
                toolTip: "Print",
                maxWidth: 40,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onClick: (context) {
                  context.goNamed('print-course-test', pathParameters: {
                    'course_id': courseId.toString(),
                    'test_id': testId.toString(),
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.edit,
                toolTip: "Edit",
                maxWidth: 40,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onClick: (context) {
                  context.goNamed('edit-course-test', pathParameters: {
                    'course_id': courseId.toString(),
                    'test_id': testId.toString(),
                  });
                },
              ),
            )
          ],
        ),
        BackgroundBody(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText("Name: ${info.name}"),
                const SizedBox(height: 5,),
                SelectableText("Duration: ${info.duration} minutes"),
              ],
            ),
          ),
        ),
        const Heading(
            headingText: "Students"
        ),
        BackgroundBody(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              User user = users[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconItem(
                    icon: const Icon(Icons.person),
                    color: Colors.green.shade700,
                    body: Text("${user.firstName} ${user.lastName} (${user.username})"),
                    onClick: (context) async {
                      context.goNamed("review-course-test", pathParameters: {
                        "course_id": courseId.toString(),
                        "test_id": testId.toString(),
                        "user_id": user.id.toString(),
                      });
                    },
                  ),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}

class _StudentBody extends StatelessWidget {
  const _StudentBody({
    required this.courseId,
    required this.testId,
    required this.remainsAttempts,
    required this.info,
    super.key
  });

  final int courseId;
  final int testId;
  final int remainsAttempts;
  final TestInfo info;

  Future<void> openPasswordDialog(BuildContext context, bool hasPassword) async {
    if (!hasPassword) {
      context.goNamed('start-course-test', pathParameters: {
        'course_id': courseId.toString(),
        'test_id': testId.toString(),
      });
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => PopupDialog(
          alignment: Alignment.center,
          child: _TestDialog(
              courseId: courseId,
              testId: testId
          )
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute < 10 ? "0" : ""}${dateTime.minute}";
  }

  Color getStatusColor(TestAttempt attempt) {
    switch(attempt.status) {
      case 'Graded': return Colors.green.shade700;
      case 'Checked': return Colors.orange.shade700;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return ListView(
      children: [
        const Heading(headingText: "Info"),
        BackgroundBody(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText("Name: ${info.name}"),
                const SizedBox(height: 5,),
                SelectableText("Duration: ${info.duration} minutes"),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width > overflow ? 50 : 15,
            vertical: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              remainsAttempts > 0 ? Builder(
                builder: (context) {
                  bool isLocked = info.attempts.isNotEmpty && info.attempts.last.status == "Checked";
                  if (isLocked) {
                    return const Text(
                      "Waiting for Last Test Review",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    );
                  }
                  return Button(
                    maxWidth: double.infinity,
                    maxHeight: 100,
                    backgroundColor: Colors.green.shade700,
                    text: "Start Test",
                    onClick: (context) {
                      openPasswordDialog(context, info.hasPassword);
                    },
                  );
                }
              ) : Container(),
              Text("Remains $remainsAttempts Attempts")
            ],
          ),
        ),
        const Heading(headingText: "Answers"),
        BackgroundBody(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: info.attempts.length,
            itemBuilder: (context, index) {
              TestAttempt attempt = info.attempts[index];
              Color background = getStatusColor(attempt);
              return IconItem(
                color: background,
                icon: Text(
                  " ${index + 1}.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getActiveTheme().calculateTextColor(background, context),
                  ),
                ),
                body: Text(
                    formatDateTime(attempt.submitted)
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("${attempt.points} b"),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}


class _TestDialog extends StatefulWidget {
  const _TestDialog({
    required this.courseId,
    required this.testId
  });

  final int courseId;
  final int testId;

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
    return await TestGateway.instance.checkTestPassword(widget.testId, passwordController.text);
  }

  Future<bool> startTest(BuildContext context) async {
    if (!await checkPassword()) {
      debugPrint('Wrong Password to Test');
      return false;
    }

    if (context.mounted) {
      context.goNamed('start-course-test', pathParameters: {
        'course_id': widget.courseId.toString(),
        'test_id': widget.testId.toString(),
      }, queryParameters: {
        'password': passwordController.text,
      });
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
                    if (mounted) context.pop();
                  } else {
                    enteredWrongPassword = true;
                    if (mounted) setState(() {});
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