
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/ui/assets/dialogs/LoadingDialog.dart';
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
              if (value) {
                context.goNamed("course-test", pathParameters: {
                "course_id": widget.courseId.toString(),
                "test_id": widget.testId.toString(),
              });
              }
            });
          } else {
            context.goNamed("course-test", pathParameters: {
              "course_id": widget.courseId.toString(),
              "test_id": widget.testId.toString(),
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
                  allowPop = true;
                  print("Load Test Error: ${snapshot.error}");
                  Toast.makeToast(text: "Failed to load Test", icon: Icons.error, iconColor: Colors.red.shade700, duration: ToastDuration.large);
                  bool isLocked = snapshot.error.toString().toLowerCase().contains("locked");
                  if (isLocked) {
                    return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Test is Locked",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 20
                          ),
                        ),
                        Text(
"""
Possible causes:
1. You've entered the wrong password
2. One of your attempts is awaiting review
3. You've reached the maximum amount of attempts for this test
""",
                          style: TextStyle(
                            color: Colors.red.shade700,
                          ),
                        ),
                        Button(
                          text: "Ok",
                          onClick: (context) {
                            context.goNamed("course-test", pathParameters: {
                              "course_id": widget.courseId.toString(),
                              "test_id": widget.testId.toString(),
                            });
                          },
                        )
                      ],
                    ),
                  );
                  } else {
                    context.goNamed("course-test", pathParameters: {
                      "course_id": widget.courseId.toString(),
                      "test_id": widget.testId.toString(),
                    });
                  }
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
      showDialog(
        context: context,
        useSafeArea: true,
        barrierDismissible: false,
        builder: (context) => const LoadingDialog(),
      );
      allowPop = await onFinishTest();
      context.pop();
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
  double scale = 1;

  @override
  void initState() {
    super.initState();
    updateTime();
    updateTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
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

      shortTime = remainsHours == 0 && remainsMinutes < 5;
      //print("$remainsHours $remainsMinutes $remainsSeconds");
      if (remainsHours == 0 && remainsMinutes < 1) {
        if (remainsSeconds <= 0) {
          widget.onTimeRunOut();
          return;
        }

        scale = scale == 1.0 ? 1.2 : 1.0;
      }

      String hours = remainsHours > 0 ? "${remainsHours}h\n" : "";
      String minutes = remainsHours > 0 || remainsMinutes > 0 ? remainsMinutes < 10 ? "0${remainsMinutes}m\n" : "${remainsMinutes}m\n" : "";
      String seconds = remainsHours > 0 || remainsMinutes > 0 || remainsSeconds > 0 ? remainsSeconds < 10 ? "0${remainsSeconds}s" : "${remainsSeconds}s" : "";
      time = "$hours$minutes$seconds";

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          color: Theme.of(context).colorScheme.secondary,
        ),
        width: 45,
        margin: EdgeInsets.only(top: height / 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Text(
                time,
                style: GoogleFonts.azeretMono().copyWith(
                  color: shortTime ? Colors.red.shade700 : Theme.of(context).textTheme.bodyMedium!.color,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 200),
                child: Button(
                  icon: Icons.done_all,
                  toolTip: "Finish",
                  maxWidth: 40,
                  backgroundColor: Colors.red.shade700,
                  onClick: (context) async {
                    widget.onFinishTest();
                  },
                ),
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
