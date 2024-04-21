import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/Review.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/ui/assets/dialogs/LoadingDialog.dart';
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
                          submissions.sort((a, b) => a.submittedAt.compareTo(b.submittedAt),);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _Body(
                              submissions: submissions,
                              test: test,
                              onUpdated: () {
                                setState(() {});
                              },
                            ),
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
    required this.onUpdated,
    super.key,
  });

  final Test test;
  final List<TestSubmission> submissions;
  final Function() onUpdated;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {

  TestSubmission? _selected;

  Future<void> saveReview(List<Review> reviews) async {
    if(_selected == null) return;
    showDialog(context: context, builder: (context) => const LoadingDialog(),);

    if (reviews.where((element) => element.points == null).isNotEmpty) {
      Toast.makeErrorToast(text: "Please Fill All Points");
      return;
    }

    bool success = await TestGateway.instance.submitReview(widget.test.id, _selected!.id, reviews);
    if (success) {
      Toast.makeSuccessToast(text: "Review Uploaded", duration: ToastDuration.large);
      setState(() {
        _selected = null;
      });
      widget.onUpdated();
      if(mounted) context.pop();
      return;
    }
    Toast.makeErrorToast(text: "Review Failed Upload");
    if(mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 900;

    if (width > overflow) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Heading(headingText: "Attempts"),
                BackgroundBody(
                    child: _Attempts(
                      submissions: widget.submissions,
                      onClicked: (submission) {
                        _selected = submission == _selected ? null : submission;
                        setState(() {});
                      },
                    )
                ),   
              ],
            ),
          ),
          Flexible(
            child: _TestEditor(
              test: widget.test,
              submission: _selected,
              onSubmit: saveReview,
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Heading(headingText: "Attempts"),
        BackgroundBody(
          child: _Attempts(
            submissions: widget.submissions,
            onClicked: (submission) {
              _selected = submission == _selected ? null : submission;
              setState(() {});
            },
          )
        ),
        _TestEditor(
          test: widget.test,
          submission: _selected,
          onSubmit: saveReview,
        ),
      ],
    );
  }
}

class _TestEditor extends StatelessWidget {
  const _TestEditor({
    required this.test,
    required this.submission,
    required this.onSubmit,
    super.key
  });

  final Test test;
  final TestSubmission? submission;
  final Function(List<Review> reviews) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Heading(headingText: "Test"),
        BackgroundBody(
          child: submission != null ? FutureBuilder(
              future: TestGateway.instance.getAnswers(test.id, submission!.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox(height: 100, child: WidgetLoading(),);
                List<AnswerOption> answers = snapshot.data!;

                return FutureBuilder(
                  future: TestGateway.instance.getReviews(test.id, submission!.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox(height: 100, child: WidgetLoading(),);
                    List<Review> reviews = snapshot.data!;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: test.questions.length,
                          itemBuilder: (context, index) {
                            Question question = test.questions[index];
                            List<AnswerOption> questionAnswers = [];
                            for(AnswerOption option in answers) {
                              if (question.id == option.questionId) {
                                questionAnswers.add(option);
                              }
                            }
                            question.setWithAnswerOptions(questionAnswers);
                            if(reviews.where((element) => element.questionId == question.id).isEmpty) {
                              Review review = Review(
                                  questionId: question.id,
                                  points: question.getPointsFromAnswers()
                              );
                              reviews.add(review);
                            }
                            return QuestionBuilderFactory(
                              question: question,
                              review: reviews.where((element) => element.questionId == question.id).single,
                            );
                          },
                        ),
                        const SizedBox(height: 25,),
                        Button(
                          text: "Save Review",
                          backgroundColor: Colors.green.shade700,
                          maxWidth: double.infinity,
                          onClick: (context) {
                            onSubmit(reviews);
                          },
                        )
                      ],
                    );
                  }
                );
              }
          ) : Container(
            alignment: Alignment.center,
            height: 100,
            child: const Text("Nothing Selected"),
          ),
        ),
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
        const SizedBox(width: 20,),
        width > overflow ? Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(isGraded ? "Checked" : "Waiting for Check",
              textAlign: TextAlign.center,
            ),
          )
        ) : Container(),
      ],
      onClick: (context) => onClicked(),
    );
  }
}
