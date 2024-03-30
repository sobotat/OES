
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilderFactory.dart';

class CourseTestTeacherInfoScreen extends StatefulWidget {
  const CourseTestTeacherInfoScreen({
    required this.courseId,
    required this.testId,
    required this.userId,
    super.key
  });

  final int courseId;
  final int testId;
  final int userId;

  @override
  State<CourseTestTeacherInfoScreen> createState() => _CourseTestTeacherInfoScreenState();
}

class _CourseTestTeacherInfoScreenState extends State<CourseTestTeacherInfoScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        onRefresh: () {
          setState(() {});
        },
      ),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          if (!AppSecurity.instance.isInit) {
            return const Center(child: WidgetLoading(),);
          }
          return FutureBuilder(
            future: TestGateway.instance.get(widget.testId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Toast.makeErrorToast(text: "Failed to get Test");
                context.pop();
              }
              if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
              Test test = snapshot.data!;

              return FutureBuilder(
                future: UserGateway.instance.getUser(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    Toast.makeErrorToast(text: "Failed to get User");
                    context.pop();
                  }
                  if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                  User user = snapshot.data!;

                  return ListView(
                    children: [
                      _Info(
                        test: test,
                        user: user,
                      ),
                      const SizedBox(height: 10,),
                      FutureBuilder(
                        future: TestGateway.instance.getUserSubmission(test.id, user.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox(height: 100, child: WidgetLoading());
                          List<TestSubmission> submissions = snapshot.data!;

                          return _Body(
                            submissions: submissions,
                            test: test,
                          );
                        }
                      )
                    ],
                  );
                }
              );
            },
          );
        }
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.test,
    required this.submissions,
    super.key,
  });

  final Test test;
  final List<TestSubmission> submissions;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {

  TestSubmission? _selected;
  set selected(TestSubmission? value) {
    _selected = value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Heading(headingText: "Attempts"),
        BackgroundBody(
          child: _Attempts(
            submissions: widget.submissions,
            onClicked: (submission) {
              selected = submission == _selected ? null : submission;
              setState(() {});
            },
          )
        ),
        _selected != null ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Heading(headingText: "Test"),
            BackgroundBody(
              child: FutureBuilder(
                future: TestGateway.instance.getAnswers(widget.test.id, _selected!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox(height: 100, child: WidgetLoading(),);
                  List<AnswerOption> answers = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.test.questions.length,
                    itemBuilder: (context, index) {
                      Question question = widget.test.questions[index];
                      List<AnswerOption> questionAnswers = [];
                      for(AnswerOption option in answers) {
                        if (question.id == option.questionId) {
                          questionAnswers.add(option);
                        }
                      }
                      question.setWithAnswerOptions(questionAnswers);
                      return QuestionBuilderFactory(
                        question: question
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ) : Container(),
      ],
    );
  }
}

class _Attempts extends StatelessWidget {
  const _Attempts({
    required this.submissions,
    required this.onClicked,
    super.key,
  });

  final List<TestSubmission> submissions;
  final Function(TestSubmission submission) onClicked;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        TestSubmission submission = submissions[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Item(
              index: index,
              submission: submission,
              onClicked: () {
                onClicked(submission);
              },
            ),
          ],
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.test,
    required this.user,
    super.key,
  });

  final Test test;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Heading(
            headingText: "Test Info"
        ),
        BackgroundBody(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText("Test Name: ${test.name}"),
                const SizedBox(height: 5,),
                SelectableText("Student: ${user.firstName} ${user.lastName} (${user.username})"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.index,
    required this.submission,
    required this.onClicked,
    super.key,
  });

  final int index;
  final TestSubmission submission;
  final Function() onClicked;

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${dateTime.minute < 10 ? "0" : ""}${dateTime.minute}";
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 500;

    bool isGraded = submission.status == "Graded";
    Color iconBackground = isGraded ? Colors.green.shade700 : Colors.deepOrange.shade700;

    return IconItem(
      icon: Text(" ${index + 1}.", style: TextStyle(color: AppTheme.getActiveTheme().calculateTextColor(iconBackground, context))),
      body: Text(formatDateTime(submission.submittedAt)),
      color: iconBackground,
      actions: [
        Text("${submission.totalPoints}b", style: const TextStyle(fontWeight: FontWeight.bold)),
        width > overflow ? SizedBox(width: 200,child: Text(isGraded ? "Checked" : "Waiting for Check", textAlign: TextAlign.center,)) : Container(),
        width <= overflow ? const SizedBox(width: 20,) : Container(),
      ],
      onClick: (context) => onClicked(),
    );
  }
}
