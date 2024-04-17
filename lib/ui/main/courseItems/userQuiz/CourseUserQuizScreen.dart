import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/restApi/interface/courseItems/UserQuizGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
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
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          if(!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
          return FutureBuilder(
            future: UserQuizGateway.instance.get(quizId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
              return _Body(
                userQuiz: snapshot.data!,
              );
            }
          );
        },
      ),
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

  @override
  void initState() {
    super.initState();
    Future(() {
      resetQuestions();
    },);
  }

  void resetQuestions() {
    questionsStack = List.from(widget.userQuiz.questions);
    questionsStack.shuffle();
    for(Question q in questionsStack) {
      q.options.shuffle();
    }
    showResult = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 3,
          color: Colors.blueAccent,
        ),
        Expanded(
          child: questionsStack.isNotEmpty ? _Question(
            question: questionsStack.first,
            showResults: showResult,
            onSubmit: (options) {
              showResult = true;
              setState(() {});
              Future.delayed(const Duration(seconds: 5), () {
                showResult = false;
                questionsStack.removeAt(0);
                if(mounted) setState(() {});
              },);
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
    super.key
  });

  final Question question;
  final bool showResults;
  final Function(List<AnswerOption> options) onSubmit;

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

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var overflow = 950;

    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Text(widget.question.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30),
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width > overflow ? 50 : 15
          ),
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  List<Widget> childrenLeft = [];
                  List<Widget> childrenRight = [];

                  bool isLeft = true;
                  for(QuestionOption option in widget.question.options) {
                    bool isSelected = selected.contains(option);
                    bool result = isSelected && option.points > 0 ? true : false;

                    Widget w = Button(
                      text: option.text,
                      maxHeight: (height / 4) / (widget.question.options.length / 2),
                      maxWidth: double.infinity,
                      backgroundColor: widget.showResults ? (option.points > 0 ? Colors.green.shade700 : Colors.red.shade700 ) : Theme.of(context).extension<AppCustomColors>()!.accent,
                      borderColor: widget.showResults ? (isSelected ? Colors.green : Colors.red ) : isSelected ? Colors.green.shade700 : null,
                      borderWidth: widget.showResults ? 8 : 4,
                      onClick: (context) {
                        if (widget.showResults) return;
                        if(selected.contains(option)) {
                          selected.remove(option);
                          setState(() {});
                          return;
                        }
                        if(widget.question is PickOneQuestion) {
                          selected.clear();
                        }
                        selected.add(option);
                        setState(() {});
                      },
                    );

                    if(isLeft) {
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
                      const SizedBox(width: 20,),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: childrenRight,
                        ),
                      ),
                    ],
                  );
                }
              ),
              !widget.showResults ? Button(
                text: "Submit",
                maxWidth: double.infinity,
                backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
                onClick: (context) {
                  List<AnswerOption> options = [];
                  for (QuestionOption o in selected) {
                    AnswerOption option = AnswerOption(questionId: widget.question.id, id: o.id, text: o.text);
                    options.add(option);
                  }
                  widget.onSubmit(options);
                },
              ) : Container(),
            ],
          ),
        ),
        const SizedBox(height: 20,)
      ],
    );
  }
}