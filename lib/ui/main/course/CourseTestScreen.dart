
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:oes/ui/assets/widgets/questions/OpenQuestionBuilder.dart';
import 'package:oes/ui/assets/widgets/questions/PickManyQuestionBuilder.dart';
import 'package:oes/ui/assets/widgets/questions/PickOneQuestionBuilder.dart';

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

  @override
  void initState() {
    super.initState();
  }

  Future<void> onFinishTest() async {
    print("Do Something Exiting Test");
    await Future.delayed(const Duration(seconds: 1));
    allowPop = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(

      ),
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
            if (AppSecurity.instance.isLoggedIn()) {
              Future.delayed(Duration.zero, () async {
                bool okPassword = await CourseGateway.instance.checkTestPassword(widget.courseId, widget.testId, widget.password);
                if (!okPassword && mounted) {
                  context.goNamed('/');
                }
              },);
            }
            return FutureBuilder(
              future: TestGateway.instance.get(widget.courseId, widget.testId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: WidgetLoading());
                test = snapshot.data;
                if (test == null) {
                  return const Center(
                    child: Text(
                      "Failed to load test",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 30),
                    ),
                  );
                }
                return _TestBody(
                  test: test!,
                  onFinishTest: () async {
                    if (!await startReallyFinishTest(context)) return;
                    if (mounted) context.pop();
                  },
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

    if (wantFinishTest) await onFinishTest();
    return Future.value(wantFinishTest);
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
            return _QuestionBuilder(question: test.questions[index]);
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

class _QuestionBuilder extends StatelessWidget {
  const _QuestionBuilder({
    required this.question,
    super.key,
  });

  final Question question;

  @override
  Widget build(BuildContext context) {
    if (question is PickOneQuestion) {
      return PickOneQuestionBuilder(question: question as PickOneQuestion);
    } else if (question is PickManyQuestion) {
      return PickManyQuestionBuilder(question: question as PickManyQuestion);
    } else if (question is OpenQuestion) {
      return OpenQuestionBuilder(question: question as OpenQuestion);
    } else {
      return Text("Question [${question.type}] is Not Supported");
    }
  }
}
