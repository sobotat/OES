
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
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
import 'package:signalr_netcore/errors.dart';
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

              return FutureBuilder(
                future: Future(() => Quiz(id: quizId, name: "Testing quiz", created: DateTime.now(), createdById: 1, isVisible: true, scheduled: DateTime.now(), end: DateTime.now().add(const Duration(days: 3)))),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: WidgetLoading());
                  Quiz quiz = snapshot.data as Quiz;

                  return _Body(
                    quiz: quiz,
                    isTeacher: isTeacher,
                  );
                },
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
    required this.quiz,
    required this.isTeacher,
    super.key
  });

  final Quiz quiz;
  final bool isTeacher;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {

  SignalR? signalR;
  _ScreenState state = _ScreenState.waiting;
  List<User> users = [];
  Question? question = PickManyQuestion(id: 1, name: "Testing", description: "Hello dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 297:3", points: 3, options: [QuestionOption(id: 1, text: "Yes", points: 3), QuestionOption(id: 1, text: "No", points: 0),QuestionOption(id: 1, text: "Maybe", points: 3),]);

  @override
  void initState() {
    super.initState();
    initSignalR();
  }

  @override
  void dispose() {
    if (signalR != null) {
      Future(() async {
        await signalR!.send("RemoveFromGroup", arguments: [AppSecurity.instance.user!.id, widget.quiz.id]);
        await signalR!.stop();
        signalR = null;
      },);
    }
    super.dispose();
  }

  Future<void> initSignalR() async {
    signalR = SignalR("signalr/quiz");
    bool started = await signalR!.start({
      "JoinGroupCallback": (arguments) {
        users = [];
        if (arguments != null && arguments.isNotEmpty) {
          for (Map<String, dynamic> argv in arguments[0] as List<dynamic>) {
            users.add(User.fromJson(argv));
          }
        }
        if (users.isNotEmpty) Toast.makeToast(text: 'Joined: ${users.last.firstName} ${users.last.lastName}');
        setState(() {});
      },
      "JoinGroupErrorCallback": (arguments) {
        Toast.makeToast(text: 'Join Error: $arguments');
        setState(() {});
      },
      "RemoveFromGroupCallback": (arguments) {
        setState(() {});
      },
      "SendAnswerErrorCallback": (arguments) {
        Toast.makeToast(text: 'Answer Error: $arguments');
        setState(() {});
      },
      "QuizFinished": (arguments) {
        if(mounted) context.pop();
      }
    }).onError((error, stackTrace) {
      Toast.makeErrorToast(text: "Quiz Connection Failed");
      return false;
    });
    if (started) {
      await signalR!.send("JoinGroup", arguments: [AppSecurity.instance.user!.id, widget.quiz.id]);
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
          color: signalR!.getState() == HubConnectionState.Connected ? Colors.green : Colors.red,
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              switch (state) {
                case _ScreenState.waiting:
                  return _Users(
                    users: users,
                    isTeacher: widget.isTeacher,
                  );
                case _ScreenState.question:
                  if (question == null) return const Center(child: WidgetLoading());
                  return _Question(
                    question: question!,
                    isTeacher: widget.isTeacher,
                  );
                case _ScreenState.result:
                  return const _Result();
                case _ScreenState.score:
                  return const _Score();
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
    super.key
  });

  final List<User> users;
  final bool isTeacher;

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
        isTeacher ? Padding(
          padding: EdgeInsets.only(
            left: width > overflow ? 50 : 15,
            right: width > overflow ? 50 : 15,
            bottom: 20
          ),
          child: Button(
            text: "Start Quiz",
            maxWidth: double.infinity,
            backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
            onClick: (context) {

            },
          ),
        ) : Button(
          text: "Show Result",
          maxWidth: double.infinity,
          backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
          onClick: (context) {

          },
        )
      ],
    );
  }
}

class _Question extends StatefulWidget {
  const _Question({
    required this.question,
    required this.isTeacher,
    super.key
  });

  final Question question;
  final bool isTeacher;

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
              style: TextStyle(fontSize: widget.isTeacher ? 60 : 30),
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width > overflow ? 50 : 15
          ),
          child: !widget.isTeacher ? Center(
            child: Builder(
              builder: (context) {
                List<Widget> children = [];
                for(QuestionOption option in widget.question.options) {
                  children.add(
                    Button(
                      text: option.text,
                      maxHeight: (height / 4) / (widget.question.options.length / 2),
                      maxWidth: (width / 2).floor() - 100,
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
                    )
                  );
                }

                return Wrap(
                  runSpacing: 20,
                  spacing: 20,
                  children: children,
                );
              }
            ),
          ) : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20,),
              Button(
                text: "Show Results",
                maxWidth: double.infinity,
                backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
                onClick: (context) {

                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,)
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _Score extends StatelessWidget {
  const _Score({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
