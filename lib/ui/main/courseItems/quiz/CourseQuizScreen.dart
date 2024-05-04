import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionFactory.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/services/SignalR.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:signalr_netcore/hub_connection.dart';

class CourseQuizScreen extends StatelessWidget {
  const CourseQuizScreen({
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
            future: Future(() async {
              Course? course = await CourseGateway.instance.getCourse(courseId);
              if (course == null) return false;
              return await course.isTeacherInCourse(AppSecurity.instance.user as User);
            }),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              bool isTeacher = snapshot.data!;

              return _Body(
                quizId: quizId,
                isTeacher: isTeacher,
              );
            }
          );
        },
      ),
    );
  }
}

enum _ScreenState {
  waiting,
  question,
  result,
  score,
}

class _Body extends StatefulWidget {
  const _Body({
    required this.quizId,
    required this.isTeacher,
    super.key
  });

  final int quizId;
  final bool isTeacher;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {

  SignalR? signalR;
  _ScreenState state = _ScreenState.waiting;
  List<User> users = [];
  List<Map<String, dynamic>> score = [];
  Question? question;
  bool submittedQuestion = false;
  int points = 0, position = 0;
  int countRemainingQuestions = 0;
  int countSubmitted = 0;

  @override
  void initState() {
    super.initState();
    initSignalR();
  }

  @override
  void dispose() {
    if (signalR != null) {
      Future(() async {
        await signalR!.send("RemoveFromGroup", arguments: [AppSecurity.instance.user!.id, widget.quizId]);
        await signalR!.stop();
        signalR = null;
      },);
    }
    super.dispose();
  }

  Future<void> initSignalR() async {
    signalR = SignalR("signalr/quiz",
      onReconnected: () async {
        await signalR!.send("JoinGroup", arguments: [AppSecurity.instance.user!.id, widget.quizId]);
        if(mounted) setState(() {});
      },
      onReconnecting: () {
        if(mounted) setState(() {});
      },
    );

    bool started = await signalR!.start({
      "JoinGroupCallback": (arguments) {
        users = [];
        if (arguments.isNotEmpty) {
          for (Map<String, dynamic> argv in arguments[0] as List<dynamic>) {
            users.add(User.fromJson(argv));
          }
        }

        if (users.isNotEmpty && (!widget.isTeacher || (AppSecurity.instance.user!.id != arguments[1]))) {
          User joined = users.where((element) => element.id == arguments[1]).single;
          Toast.makeToast(text: 'Joined: ${joined.firstName} ${joined.lastName}');
        }
        setState(() {});
      },
      "RemoveFromGroupCallback": (arguments) {
        users = [];
        if (arguments.isNotEmpty && arguments[0] is! String) {
          for (Map<String, dynamic> argv in arguments[0] as List<dynamic>) {
            users.add(User.fromJson(argv));
          }
        }
        setState(() {});
      },
      "SubmitAnswerCallback": (arguments) {
        countSubmitted += 1;
        setState(() {});
      },
      "NextQuestionCallback": (arguments) {
        state = _ScreenState.question;
        if (arguments.isNotEmpty) {
          countSubmitted = 0;
          question = QuestionFactory.fromJson(arguments[0] as Map<String, dynamic>);
          question!.options.shuffle();
          submittedQuestion = false;
        }
        setState(() {});
      },
      "ShowCurrentQuestionResultsCallback": (arguments) {
        state = _ScreenState.result;
        if (!widget.isTeacher && arguments.isNotEmpty) {
          Map<String, dynamic> data = Map.from(arguments[0]);
          String user = AppSecurity.instance.user!.id.toString();
          if (data.containsKey(user)) {
            points = data[user]!["points"]!;
            position = data[user]!["position"]!;
          } else {
            points = -1;
            position = -1;
          }
        }

        if (widget.isTeacher) {
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              signalR!.send("ShowResults", arguments: [AppSecurity.instance.user!.id, widget.quizId]);
            }
          },);
        }
        setState(() {});
      },
      "ShowResultsCallback": (arguments) {
        state = _ScreenState.score;
        if (arguments.isNotEmpty) {
          score = [];
          for (Map<String, dynamic> json in arguments[0]) {
            int points = json.remove("points");
            User user = User.fromJson(json);
            score.add({
              "user": user,
              "points": points,
            });
          }
        }
        countRemainingQuestions = arguments[1];
        setState(() {});
      },

      "QuizFinished": (arguments) {
        state = _ScreenState.waiting;
        Toast.makeToast(text: "Finished");
        setState(() {});
      },
      "QuizQuit": (arguments) {
        if(mounted) context.pop();
      }
    }).onError((error, stackTrace) {
      Toast.makeErrorToast(text: "Quiz Connection Failed");
      return false;
    });
    if (started) {
      await signalR!.send("JoinGroup", arguments: [AppSecurity.instance.user!.id, widget.quizId]);
      if(mounted) setState(() {});
    } else {
      signalR = null;
      if(mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (signalR == null) {
      return const Center(child: WidgetLoading(),);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 3,
          color: signalR!.getState() == HubConnectionState.Connected ? Colors.green : signalR!.getState() == HubConnectionState.Reconnecting ? Colors.orange : Colors.red,
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              switch (state) {
                case _ScreenState.waiting:
                  return _Users(
                    users: users,
                    isTeacher: widget.isTeacher,
                    onStart: () {
                      signalR!.send("NextQuestion", arguments: [AppSecurity.instance.user!.id, widget.quizId, true]);
                    },
                  );
                case _ScreenState.question:
                  if (question == null) return const Center(child: WidgetLoading());
                  return _Question(
                    question: question!,
                    submitted: submittedQuestion,
                    countSubmitted: countSubmitted,
                    countUsers: users.length,
                    isTeacher: widget.isTeacher,
                    onSubmit: (options) {
                      List<Map<String, dynamic>> answers = [];
                      for(AnswerOption option in options) {
                        submittedQuestion = true;
                        answers.add({
                          "optionId": option.id,
                          "questionId": option.questionId,
                          "submittedAt": DateTime.now().toUtc().toString().replaceAll(' ', 'T')
                        });
                      }
                      setState(() {});
                      signalR!.send("SubmitAnswer", arguments: [AppSecurity.instance.user!.id, widget.quizId, answers]);
                    },
                    onShowResult: () {
                      signalR!.send("ShowCurrentQuestionResults", arguments: [AppSecurity.instance.user!.id, widget.quizId]);
                    },
                  );
                case _ScreenState.result:
                  return _Result(
                    points: points,
                    position: position,
                    countOfUsers: users.length,
                    isTeacher: widget.isTeacher,
                  );
                case _ScreenState.score:
                  return _Score(
                    score: score,
                    isTeacher: widget.isTeacher,
                    remainingQuestions: countRemainingQuestions,
                    onNextQuestion: () {
                      signalR!.send("NextQuestion", arguments: [AppSecurity.instance.user!.id, widget.quizId, false]);
                    },
                  );
                default:
                  throw UnimplementedError();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _Users extends StatelessWidget {
  const _Users({
    required this.users,
    required this.isTeacher,
    required this.onStart,
    super.key
  });

  final List<User> users;
  final bool isTeacher;
  final Function() onStart;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Column(
      children: [
        Heading(
          headingText: "Joined Users",
          actions: [
            Text("${users.length} ${users.length == 1 ? "User" : "Users"} Joined")
          ],
        ),
        Flexible(
          child: BackgroundBody(
            child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  User user = users[index];
                  return IconItem(
                    icon: const Icon(Icons.person),
                    body: Text("${user.firstName} ${user.lastName}"),
                  );
                }
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: width > overflow ? 50 : 15,
              right: width > overflow ? 50 : 15,
              bottom: 20
          ),
          child: isTeacher ? Button(
            text: "Start Quiz",
            maxWidth: double.infinity,
            backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
            onClick: (context) {
              onStart();
            },
          ) : const Text("Waiting for teacher to start Quiz",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        )
      ],
    );
  }
}

class _Question extends StatefulWidget {
  const _Question({
    required this.question,
    required this.isTeacher,
    required this.submitted,
    required this.countSubmitted,
    required this.countUsers,
    required this.onSubmit,
    required this.onShowResult,
    super.key
  });

  final Question question;
  final bool isTeacher;
  final bool submitted;
  final int countSubmitted;
  final int countUsers;
  final Function(List<AnswerOption> options) onSubmit;
  final Function() onShowResult;

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
            child: AppMarkdown(
              data: widget.question.description,
              textAlign: widget.question.description.contains("#") ? WrapAlignment.start : WrapAlignment.center,
              testSize: widget.isTeacher ? 35 : 25,
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width > overflow ? 50 : 15
          ),
          child: !widget.isTeacher && !widget.submitted ? Column(
            children: [
              Center(
                child: Builder(
                  builder: (context) {
                    List<Widget> childrenLeft = [];
                    List<Widget> childrenRight = [];
                    
                    bool isLeft = true;
                    for(QuestionOption option in widget.question.options) {
                      Widget w = Button(
                        text: option.text,
                        maxHeight: (height / 4) / (widget.question.options.length / 2),
                        maxWidth: double.infinity,
                        backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
                        borderColor: selected.contains(option) ? Colors.green.shade700 : null,
                        borderWidth: 4,
                        onClick: (context) {
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
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button(
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
                  )
                ],
              ),
            ],
          ) :
          widget.isTeacher ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20,),
              Text("Submitted ${widget.countSubmitted}/${widget.countUsers}", textAlign: TextAlign.center,),
              const SizedBox(height: 5,),
              Button(
                text: "Show Results",
                maxWidth: double.infinity,
                backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
                onClick: (context) {
                  widget.onShowResult();
                },
              ),
            ],
          ) : Container(),
        ),
        const SizedBox(height: 20,)
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.points,
    required this.position,
    required this.countOfUsers,
    required this.isTeacher,
    super.key
  });

  final int points;
  final int position;
  final int countOfUsers;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    if (isTeacher) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Please wait", style: TextStyle(fontSize: 45)),
          Text("Others are looking at result", style: TextStyle(fontSize: 30),)
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Got $points Points", style: const TextStyle(fontSize: 45),),
        Text("Position $position/$countOfUsers", style: const TextStyle(fontSize: 30),)
      ],
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({
    required this.score,
    required this.isTeacher,
    required this.remainingQuestions,
    required this.onNextQuestion,
    super.key
  });

  final List<Map<String, dynamic>> score;
  final bool isTeacher;
  final int remainingQuestions;
  final Function() onNextQuestion;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Column(
      children: [
        const Heading(
          headingText: "Scores",
        ),
        Flexible(
          child: BackgroundBody(
            child: ListView.builder(
                itemCount: score.length,
                itemBuilder: (context, index) {
                  Map<String,dynamic> s = score[index];
                  User user = s['user'];
                  int points = s['points'];

                  return IconItem(
                    icon: Text(" ${index + 1}."),
                    body: Text("${user.firstName} ${user.lastName} (${user.username})"),
                    actions: [
                      Text("${points}b")
                    ],
                  );
                }
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: width > overflow ? 50 : 15,
              right: width > overflow ? 50 : 15,
              bottom: 20
          ),
          child: isTeacher ? Button(
            text: remainingQuestions != 0 ? "Next Question [Questions to go $remainingQuestions]" : "Finish Quiz",
            maxWidth: double.infinity,
            backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
            onClick: (context) {
              onNextQuestion();
            },
          ) : remainingQuestions != 0 ? Text("Waiting for teacher to start next Question [Questions to go $remainingQuestions]",
            style: TextStyle(fontStyle: FontStyle.italic),
          ) : Container(),
        )
      ],
    );
  }
}
