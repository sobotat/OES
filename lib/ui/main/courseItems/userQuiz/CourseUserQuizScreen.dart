import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppSettings.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/restApi/interface/courseItems/UserQuizGateway.dart';
import 'package:oes/ui/assets/templates/AnimatedProgressIndicator.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseUserQuizScreen extends StatelessWidget {
  const CourseUserQuizScreen({
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

    return ListenableBuilder(
      listenable: AppSecurity.instance,
      builder: (context, child) {
        if(!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
        return FutureBuilder(
            future: UserQuizGateway.instance.get(quizId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
              UserQuiz userQuiz = snapshot.data!;

              return Scaffold(
                appBar: AppAppBar(
                  title: width > overflow ? Text(userQuiz.name) : null,
                ),
                body: _Body(
                  userQuiz: userQuiz,
                ),
              );
            }
        );
      },
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.userQuiz,
    super.key
  });

  final UserQuiz userQuiz;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {

  List<Question> questionsStack = [];
  bool showResult = false;
  bool haveBadAnswer = false;

  @override
  void initState() {
    resetQuestions();
    super.initState();
  }

  void resetQuestions() {
    questionsStack = List.from(widget.userQuiz.questions);

    if(widget.userQuiz.shuffleQuestions) {
      questionsStack.shuffle();
    }

    for(Question q in questionsStack) {
      q.options.shuffle();
    }

    showResult = false;
    haveBadAnswer = false;
  }

  void showNext() {
    Question oldQuestion = questionsStack.removeAt(0);
    if(haveBadAnswer && AppSettings.instance.enableQuestionRepeating) {
      oldQuestion.options.shuffle();
      questionsStack.add(oldQuestion);
    }

    showResult = false;
    haveBadAnswer = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1 - (questionsStack.length - (showResult && !haveBadAnswer ? 1 : 0)) / widget.userQuiz.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedProgressIndicator(
          value: progress,
          startColor: Theme.of(context).extension<AppCustomColors>()!.accent,
          endColor: Colors.green,
        ),
        Expanded(
          child: questionsStack.isNotEmpty ? _Question(
            question: questionsStack.first,
            showResults: showResult,
            onSubmit: (options, haveBadAnswer) {
              this.haveBadAnswer = haveBadAnswer;
              showResult = true;
              setState(() {});
            },
            showNext: () {
              showNext();
            },
          ) : Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(20)
              ),
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Quiz Finished", style: TextStyle(fontSize: 30),),
                  const SizedBox(height: 10,),
                  Button(
                    text: "Restart",
                    maxWidth: double.infinity,
                    onClick: (context) {
                      resetQuestions();
                    },
                  ),
                  const SizedBox(height: 10,),
                  Button(
                    text: "Quit",
                    maxWidth: double.infinity,
                    onClick: (context) {
                      context.pop();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Question extends StatefulWidget {
  const _Question({
    required this.question,
    required this.showResults,
    required this.onSubmit,
    required this.showNext,
    super.key
  });

  final Question question;
  final bool showResults;
  final Function(List<AnswerOption> options, bool haveBadAnswer) onSubmit;
  final Function() showNext;

  @override
  State<_Question> createState() => _QuestionState();
}

class _QuestionState extends State<_Question> {

  List<QuestionOption> selected = [];

  @override
  void dispose() {
    selected.clear();
    super.dispose();
  }

  void submit() {
    List<AnswerOption> options = [];
    for (QuestionOption o in selected) {
      AnswerOption option = AnswerOption(questionId: widget.question.id, id: o.id, text: o.text);
      options.add(option);
    }
    widget.onSubmit(options, haveBadAnswer());
    setState(() {});
  }

  bool haveBadAnswer() {
    bool everythingOk = true;
    String qType = widget.question.type;

    for(QuestionOption option in widget.question.options) {
      bool isSelected = selected.contains(option);
      if(qType == "pick-one") {
        if(isSelected && option.points <= 0) {
          everythingOk = false;
          break;
        }
      } else {
        if((isSelected && option.points <= 0) || (!isSelected && option.points > 0)) {
          everythingOk = false;
          break;
        }
      }
    }
    return !everythingOk;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: [
                AppMarkdown(
                  data: widget.question.description,
                  textAlign: widget.question.description.contains("#") ? WrapAlignment.start : WrapAlignment.center,
                  testSize: 28,
                ),
              ]
            )
          ),
        ),
        _QuestionSelector(
          question: widget.question,
          showResults: widget.showResults,
          selected: selected,
          onUpdated: () {
            setState(() {});
          },
          onSubmit: () => submit(),
        ),
        _QuestionButtons(
          questionType: widget.question.type,
          showResults: widget.showResults,
          onSubmit: () => submit(),
          onShowNext: () {

            widget.showNext();
            selected.clear();
            setState(() {});
          },
        )
      ],
    );
  }
}

class _QuestionButtons extends StatelessWidget {
  const _QuestionButtons({
    required this.questionType,
    required this.showResults,
    required this.onSubmit,
    required this.onShowNext,
    super.key
  });

  final String questionType;
  final bool showResults;
  final Function() onShowNext;
  final Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width > overflow ? 50 : 15,
            vertical: 15
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            !showResults && questionType != "pick-one" ? Button(
              text: "Submit",
              maxWidth: double.infinity,
              backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
              onClick: (context) => onSubmit(),
            ) : Container(),
            showResults ? Button(
                text: "Continue",
                maxWidth: double.infinity,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                icon: Icons.play_arrow_outlined,
                onClick: (context) {
                  onShowNext();
                }
            ) : Container(),
          ],
        ),
      ),
    );
  }
}


class _QuestionSelector extends StatelessWidget {
  const _QuestionSelector({
    required this.question,
    required this.showResults,
    required this.selected,
    required this.onUpdated,
    required this.onSubmit,
    super.key
  });

  final Question question;
  final bool showResults;
  final List<QuestionOption> selected;
  final Function() onUpdated;
  final Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var overflow = 950;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width > overflow ? 50 : 15
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: height / 2.5
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Builder(
                builder: (context) {
                  List<Widget> childrenLeft = [];
                  List<Widget> childrenRight = [];

                  bool isLeft = true;
                  for(QuestionOption option in question.options) {
                    bool isSelected = selected.contains(option);

                    double calculatedHeight = (height / 4) / (question.options.length / 2) / (width < overflow ? 2 : 1);
                    Color backgroundColor = Theme.of(context).colorScheme.primary;
                    Widget w = Button(
                      text: option.text,
                      textSize: 16,
                      minHeight: calculatedHeight,
                      maxHeight: double.infinity,
                      maxWidth: double.infinity,
                      backgroundColor: showResults ? (option.points > 0 ? Colors.green.shade700 : Colors.red.shade700 ) : backgroundColor,
                      borderColor: showResults ? (isSelected ? Colors.green : Colors.red ) : isSelected ? Colors.green.shade700 : backgroundColor,
                      borderWidth: 8,
                      onClick: (context) {
                        if (showResults) return;
                        if(selected.contains(option)) {
                          selected.remove(option);
                          onUpdated();
                          return;
                        }
                        if(question is PickOneQuestion) {
                          selected.clear();
                        }
                        selected.add(option);
                        onUpdated();

                        if (question.type == "pick-one") {
                          onSubmit();
                        }
                      },
                    );

                    if(isLeft || width < overflow) {
                      childrenLeft.add(w);
                      childrenLeft.add(const SizedBox(height: 20,));
                    } else {
                      childrenRight.add(w);
                      childrenRight.add(const SizedBox(height: 20,));
                    }

                    isLeft = !isLeft;
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: childrenLeft,
                        ),
                      ),
                      width >= overflow ? const SizedBox(width: 20,) : Container(),
                      width >= overflow ? Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: childrenRight,
                        ),
                      ) : Container(),
                    ],
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}
