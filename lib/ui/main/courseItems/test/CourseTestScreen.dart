
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilderFactory.dart';

class CourseTestScreen extends StatefulWidget {
  const CourseTestScreen({
    required this.courseId,
    required this.testId,
    required this.password,
    super.key
  });

  final int courseId;
  final int testId;
  final String password;

  @override
  State<CourseTestScreen> createState() => _CourseTestScreenState();
}

class _CourseTestScreenState extends State<CourseTestScreen> {

  Test? test;
  bool allowPop = false;

  Future<bool> onFinishTest() async {
    if(test == null) return false;

    List<AnswerOption> answers = [];
    for(Question question in test!.questions) {
      answers.addAll(question.getAnswerOptions());
    }

    bool success = await TestGateway.instance.submit( widget.testId, answers);
    if (!success) {
      Toast.makeToast(text: "Failed to Finish Test", icon: Icons.error, iconColor: Colors.red.shade700, duration: ToastDuration.large);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: PopScope(
        canPop: allowPop,
        onPopInvoked: (didPop) async {
          if (!allowPop) {
            startReallyFinishTest(context).then((value) {
              if (value) context.pop();
            });
          }
        },
        child: ListenableBuilder(
          listenable: AppSecurity.instance,
          builder: (context, child) {
            if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
            return FutureBuilder(
              future: TestGateway.instance.get(widget.testId, password: widget.password),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("Load Test Error: ${snapshot.error}");
                  Toast.makeToast(text: "Failed to load Test", icon: Icons.error, iconColor: Colors.red.shade700, duration: ToastDuration.large);
                  context.pop();
                }
                if (!snapshot.hasData) return const Center(child: WidgetLoading());
                test = snapshot.data!;
                DateTime startTime = DateTime.now();
                return Stack(
                  children: [
                    _TestBody(
                      test: test!,
                      onFinishTest: () async {
                        if (!await startReallyFinishTest(context)) return;
                        if (mounted) context.pop();
                      },
                    ),
                    _InfoBar(
                      startTime: startTime,
                      duration: test!.duration,
                      onFinishTest: () async {
                        if (!await startReallyFinishTest(context)) return;
                        if (mounted) context.pop();
                      },
                      onTimeRunOut: () async {
                        await onFinishTest();
                        allowPop = true;
                        if (mounted) context.pop();
                      },
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> startReallyFinishTest(BuildContext context) async {
    bool wantFinishTest = false;
    await showDialog(
      context: context,
      builder: (context) => PopupDialog(
        child: Material(
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
                  child: Text('Finish Test', style: TextStyle(fontSize: 40)),
                ),
                SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Button(
                        text: 'No',
                        onClick: (context) {
                          wantFinishTest = false;
                          context.pop();
                        },
                        maxWidth: 140,
                      ),
                      Button(
                        text: 'Yes',
                        onClick: (context) {
                          wantFinishTest = true;
                          context.pop();
                        },
                        maxWidth: 140,
                        backgroundColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (wantFinishTest) {
      allowPop = await onFinishTest();
    }
    return allowPop;
  }
}

class _InfoBar extends StatefulWidget {
  const _InfoBar({
    required this.startTime,
    required this.duration,
    required this.onFinishTest,
    required this.onTimeRunOut,
    super.key,
  });

  final DateTime startTime;
  final int duration;
  final Function() onFinishTest;
  final Function() onTimeRunOut;

  @override
  State<_InfoBar> createState() => _InfoBarState();
}

class _InfoBarState extends State<_InfoBar> {

  late Timer updateTimer;
  String time = "Loading ...";
  bool shortTime = false;

  @override
  void initState() {
    super.initState();
    updateTime();
    updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTime();
    },);
  }

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }

  void updateTime() {
    if (mounted) {
      DateTime now = DateTime.now();
      int totalSeconds = widget.duration * 60 - now.difference(widget.startTime).inSeconds + 1;
      int remainsHours = (totalSeconds ~/ 60) ~/ 60;
      int remainsMinutes = (totalSeconds ~/ 60) % 60;
      int remainsSeconds = totalSeconds % 60;

      shortTime = remainsHours == 0 && remainsMinutes <= 5;
      //print("$remainsHours $remainsMinutes $remainsSeconds");
      if (remainsHours == 0 && remainsMinutes < 1) {
        if (remainsSeconds <= 1) {
          widget.onTimeRunOut();
          return;
        }

        time = "Remains ${remainsSeconds}s";
      } else {
        time = "Remains ${remainsHours > 0 ? "${remainsHours}h" : ""} ${remainsHours > 0 && remainsMinutes < 10 ? "0" : ""}${remainsMinutes}m ${remainsSeconds < 10 ? "0" : ""}${remainsSeconds}s";
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          color: Theme.of(context).colorScheme.secondary,
        ),
        width: 45,
        margin: const EdgeInsets.only(top: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: RotatedBox(quarterTurns: 1,
                child: Text(
                  time,
                  style: TextStyle(color: shortTime ? Colors.red.shade700 : Theme.of(context).textTheme.bodyMedium!.color),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.done_all,
                toolTip: "Finish",
                maxWidth: 40,
                backgroundColor: Colors.red.shade700,
                onClick: (context) async {
                  widget.onFinishTest();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TestBody extends StatelessWidget {
  const _TestBody({
    required this.test,
    required this.onFinishTest,
  });

  final Test test;
  final Function() onFinishTest;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return ListView(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: test.questions.length,
          itemBuilder: (context, index) {
            return QuestionBuilderFactory(question: test.questions[index]);
          },
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: width > overflow ? 50 : 15,
            right: width > overflow ? 50 : 15
          ),
          child: Button(
            text: "Finish Test",
            maxWidth: double.infinity,
            backgroundColor: Colors.red,
            onClick: (context) {
              onFinishTest();
            },
          ),
        )
      ],
    );
  }
}
