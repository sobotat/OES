
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/restApi/interface/courseItems/QuizGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/DateTimeItem.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilderFactory.dart';

class CourseQuizEditScreen extends StatefulWidget {
  const CourseQuizEditScreen({
    required this.courseId,
    required this.quizId,
    super.key
  });

  final int courseId;
  final int quizId;

  @override
  State<CourseQuizEditScreen> createState() => _CourseQuizEditScreenState();
}

class _CourseQuizEditScreenState extends State<CourseQuizEditScreen> {

  bool isNew() { return widget.quizId == -1; }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, x) {
          if (!AppSecurity.instance.isInit) return const Material(child: Center(child: WidgetLoading(),),);
          return FutureBuilder(
            future: Future(() async {
              if (!isNew()) {
                return await QuizGateway.instance.get(widget.quizId);
              }

              return Quiz(id: -1, name: "", created: DateTime.now(), createdById: AppSecurity.instance.user!.id, scheduled: DateTime.now(), end: DateTime.now(), isVisible: true, questions: [
                PickOneQuestion(id: -1, name: "Pick One", description: "Description", points: 0, options: [
                  QuestionOption(id: -1, text: "Option 1", points: 0),
                  QuestionOption(id: -1, text: "Option 2", points: 3),
                  QuestionOption(id: -1, text: "Option 3", points: 0)
                ]),
                PickManyQuestion(id: -1, name: "Pick Many", description: "Description", points: 0, options: [
                  QuestionOption(id: -1, text: "Option 1", points: 3),
                  QuestionOption(id: -1, text: "Option 2", points: 0),
                  QuestionOption(id: -1, text: "Option 3", points: 3)
                ])
              ],);
            },),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Toast.makeErrorToast(text: "Failed to load Quiz");
                print(snapshot.error);
                context.pop();
              }
              if (!snapshot.hasData) return const Material(child: Center(child: WidgetLoading(),));
              Quiz quiz = snapshot.data!;

              return _Body(
                  isNew: isNew(),
                  courseId: widget.courseId,
                  quiz: quiz
              );
            },
          );
        }
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.isNew,
    required this.courseId,
    required this.quiz,
    super.key
  });

  final bool isNew;
  final int courseId;
  final Quiz quiz;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {

  late TabController tabController;
  Timer updateTimer = Timer(const Duration(seconds: 1), () { });
  GlobalKey<_PreviewState> previewKey = GlobalKey<_PreviewState>();

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    tabController.dispose();
    updateTimer.cancel();
    super.dispose();
  }

  void addQuestion(String questionType) {
    List<QuestionOption> options = [
      QuestionOption(id: -1, text: "Option 1", points: 0),
      QuestionOption(id: -1, text: "Option 2", points: 0),
      QuestionOption(id: -1, text: "Option 3", points: 0)
    ];

    switch(questionType) {
      case "pick-one":
        widget.quiz.questions.add(PickOneQuestion(id: -1, name: "Pick One", description: "Description", points: 0, options: options));
        break;
      case "pick-many":
        widget.quiz.questions.add(PickManyQuestion(id: -1, name: "Pick Many", description: "Description", points: 0, options: options));
        break;
      default:
        print("Add Question Failed -> Type [$questionType] is Not Supported");
        return;
    }

    setState(() {});
  }

  void onUpdated() {
    _PreviewState? previewState = previewKey.currentState;
    if (previewState != null && previewState.mounted) {
      previewState.setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 900;

    if (width > overflow) {
      return Scaffold(
        appBar: const AppAppBar(),
        body: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: _Editor(
                    isNew: widget.isNew,
                    courseId: widget.courseId,
                    quiz: widget.quiz,
                    onUpdated: () {
                      onUpdated();
                    },
                  )
                ),
                Flexible(
                    flex: 1,
                    child: _Preview(
                      quiz: widget.quiz,
                      key: previewKey,
                    )
                ),
              ],
            )
          ],
        ),
        floatingActionButton: _AddButton(
          onSelectedType: (type) {
            addQuestion(type);
          },
        ),
      );
    }
    return Scaffold(
      appBar: const AppAppBar(),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            labelStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontWeight: FontWeight.bold
            ),
            indicatorColor: Theme.of(context).extension<AppCustomColors>()!.accent,
            tabs: const [
              Tab(text: 'Editor',),
              Tab(text: 'Preview',),
            ],
          ),
          Flexible(
            child: TabBarView(
                controller: tabController,
                children: [
                  ListView(
                    shrinkWrap: true,
                    children: [
                      _Editor(
                        isNew: widget.isNew,
                        courseId: widget.courseId,
                        quiz: widget.quiz,
                        onUpdated: () {
                          onUpdated();
                        },
                      ),
                    ],
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: [
                      _Preview(
                        quiz: widget.quiz,
                        key: previewKey,
                      ),
                    ],
                  )
                ]
            ),
          ),
        ],
      ),
      floatingActionButton: _AddButton(
        onSelectedType: (type) {
          addQuestion(type);
        },
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.onSelectedType,
    super.key,
  });

  final Function(String type) onSelectedType;

  void showSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return PopupDialog(
          alignment: Alignment.center,
          child: Container(
            width: 335,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.background,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Add",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _BigIconButton(
                        icon: Icons.looks_one_rounded,
                        text: "Pick One",
                        onClick: () {
                          onSelectedType('pick-one');
                          context.pop();
                        },
                      ),
                      _BigIconButton(
                        icon: Icons.looks_two_rounded,
                        text: "Pick Many",
                        onClick: () {
                          onSelectedType('pick-many');
                          context.pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'add',
      tooltip: 'Add Question',
      child: const Icon(Icons.add),
      onPressed: () {
        showSelectDialog(context);
      },
    );
  }
}

class _BigIconButton extends StatelessWidget {

  const _BigIconButton({
    required this.icon,
    required this.text,
    required this.onClick,
    super.key,
  });

  final IconData icon;
  final String text;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onClick,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.secondary,
          ),
          width: 150,
          height: 150,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                  size: 60,
                ),
                Text(text),
              ]
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatefulWidget {
  const _Preview({
    required this.quiz,
    super.key,
  });

  final Quiz quiz;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.quiz.questions.length,
          itemBuilder: (context, index) {
            return QuestionBuilderFactory(question: widget.quiz.questions[index]);
          },
        ),
      ],
    );
  }
}

class _Editor extends StatefulWidget {
  const _Editor({
    required this.isNew,
    required this.courseId,
    required this.quiz,
    required this.onUpdated,
    super.key,
  });

  final bool isNew;
  final int courseId;
  final Quiz quiz;
  final Function() onUpdated;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {

  Future<void> save() async {

    if (widget.quiz.name.isEmpty) {
      Toast.makeErrorToast(text: "Name cannot be Empty", duration: ToastDuration.large);
      return;
    }

    Quiz? response = widget.isNew ? await QuizGateway.instance.create(widget.courseId, widget.quiz) :
                                    await QuizGateway.instance.update(widget.quiz);

    if (response != null) {
      Toast.makeSuccessToast(text: "Quiz was Saved", duration: ToastDuration.short);
      context.pop();
      return;
    }

    Toast.makeErrorToast(text: "Failed to Save Quiz", duration: ToastDuration.large);
  }

  Future<void> delete() async {
    if(widget.isNew) return;
    bool success = await QuizGateway.instance.delete(widget.quiz.id);
    if (success) {
      Toast.makeSuccessToast(text: "Quiz was Deleted", duration: ToastDuration.short);
      if (mounted) {
        context.goNamed("course", pathParameters: {
          "course_id": widget.courseId.toString(),
        });
      }
      return;
    }
    Toast.makeErrorToast(text: "Failed to Delete Quiz", duration: ToastDuration.large);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Heading(
          headingText: widget.isNew ? "Create Quiz" : "Edit Quiz",
          actions: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.save,
                toolTip: "Save",
                maxWidth: 40,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onClick: (context) {
                  save();
                },
              ),
            ),
            !widget.isNew ? Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.delete,
                toolTip: "Delete",
                maxWidth: 40,
                backgroundColor: Colors.red.shade700,
                onClick: (context) {
                  delete();
                },
              ),
            ) : Container()
          ],
        ),
        _Info(
          quiz: widget.quiz,
        ),
        const SizedBox(height: 10,),
        const Heading(
          headingText: "Questions",
        ),
        _QuestionsBody(
          quiz: widget.quiz,
          onUpdated: () {
            widget.onUpdated();
          },
        )
      ],
    );
  }
}

class _QuestionsBody extends StatefulWidget {
  const _QuestionsBody({
    required this.quiz,
    required this.onUpdated,
    super.key,
  });

  final Quiz quiz;
  final Function() onUpdated;

  @override
  State<_QuestionsBody> createState() => _QuestionsBodyState();
}

class _QuestionsBodyState extends State<_QuestionsBody> {
  @override
  Widget build(BuildContext context) {
    return BackgroundBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.quiz.questions.length,
            itemBuilder: (context, index) {
              return _QuestionEditor(
                index: index,
                question: widget.quiz.questions[index],
                onUpdated: (index) {
                  widget.onUpdated();
                },
                onDeleted: (index) {
                  widget.quiz.questions.removeAt(index);
                  widget.onUpdated();
                  setState(() {});
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuestionEditor extends StatefulWidget {
  const _QuestionEditor({
    required this.index,
    required this.question,
    required this.onUpdated,
    required this.onDeleted,
    super.key
  });

  final int index;
  final Question question;
  final Function(int index) onUpdated;
  final Function(int index) onDeleted;

  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {

  TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  String capitalize(String text) {
    return "${text[0].toUpperCase()}${text.substring(1)}";
  }

  @override
  Widget build(BuildContext context) {
    String niceType = widget.question.type.replaceAll('-', ' ').split(' ').map((word) => capitalize(word)).join(' ');
    descriptionController.text = widget.question.description;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary,
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          niceType,
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Button(
                              icon: Icons.delete,
                              toolTip: "Delete",
                              maxWidth: 40,
                              backgroundColor: Colors.red.shade700,
                              onClick: (context) {
                                widget.onDeleted(widget.index);
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const HeadingLine(),
                ],
              ),
              Flexible(
                child: TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Question",
                    labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: (value) {
                    widget.question.description = value;
                    widget.onUpdated(widget.index);
                  },
                ),
              ),
              const SizedBox(height: 20,),
              _QuestionOptionsEditorFactory(
                question: widget.question,
                onUpdated: () {
                  widget.onUpdated(widget.index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionOptionsEditorFactory extends StatefulWidget {
  const _QuestionOptionsEditorFactory({
    required this.question,
    required this.onUpdated,
    super.key
  });

  final Question question;
  final Function() onUpdated;

  @override
  State<_QuestionOptionsEditorFactory> createState() => _QuestionOptionsEditorFactoryState();
}

class _QuestionOptionsEditorFactoryState extends State<_QuestionOptionsEditorFactory> {
  void recalculatePoints() {
    if (widget.question.type == "pick-one") {
      int max = 0;
      for(int points in widget.question.options.map((e) => e.points).toList()){
        if (points > max) max = points;
      }
      widget.question.points = max;
      return;
    }
    widget.question.points = 0;
    for (QuestionOption option in widget.question.options) {
      if (option.points <= 0) continue;
      widget.question.points += option.points;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch(widget.question.type) {
      case 'pick-one':
      case 'pick-many':
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.question.options.length,
            itemBuilder: (context, index) {
              return _PickOptions(
                index: index,
                option: widget.question.options[index],
                onUpdated: (index) {
                  recalculatePoints();
                  widget.onUpdated();
                },
                onDeleted: (index) {
                  widget.question.options.removeAt(index);
                  recalculatePoints();
                  widget.onUpdated();
                  setState(() {});
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Button(
              text: "Add Option",
              icon: Icons.add,
              maxWidth: double.infinity,
              backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
              onClick: (context) {
                widget.question.options.add(QuestionOption(id: -1, text: "New Option", points: 0));
                widget.onUpdated();
                setState(() {});
              },
            ),
          )
        ],
      );
      default:
        return const Placeholder();
    }
  }
}

class _PickOptions extends StatefulWidget {
  const _PickOptions({
    required this.index,
    required this.option,
    required this.onUpdated,
    required this.onDeleted,
    super.key,
  });

  final int index;
  final QuestionOption option;
  final Function(int index) onUpdated;
  final Function(int index) onDeleted;

  @override
  State<_PickOptions> createState() => _PickOptionsState();
}

class _PickOptionsState extends State<_PickOptions> {

  TextEditingController textController = TextEditingController();
  TextEditingController pointsController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    textController.text = widget.option.text;
    pointsController.text = widget.option.points.toString();

    Color color = Theme.of(context).extension<AppCustomColors>()!.accent;
    return IconItem(
      icon: Text(
        " ${widget.index + 1}.",
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontSize: 12,
            color: AppTheme.getActiveTheme().calculateTextColor(color, context)
        ),
      ),
      body: Row(
        children: [
          Flexible(
            child: TextField(
              controller: textController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Option Text",
                counter: Container(height: 0,),
              ),
              maxLines: 1,
              maxLength: 60,
              onChanged: (value) {
                widget.option.text = value;
                widget.onUpdated(widget.index);
              },
            ),
          ),
          const SizedBox(width: 5,),
          SizedBox(
            width: 75,
            child: TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Points +/-",
                counter: Container(height: 0,),
              ),
              maxLines: 1,
              maxLength: 10,
              onChanged: (value) {
                if (value == "-") return;
                try {
                  widget.option.points = int.parse(value);
                } on FormatException catch (_) {
                  widget.option.points = 0;
                  pointsController.text = '0';
                }
                widget.onUpdated(widget.index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Button(
              icon: Icons.delete,
              toolTip: "Delete",
              maxWidth: 40,
              backgroundColor: Colors.red.shade700,
              onClick: (context) {
                widget.onDeleted(widget.index);
              },
            ),
          )
        ],
      ),
      height: 65,
      color: color,
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }
}



class _Info extends StatefulWidget {
  const _Info({
    required this.quiz,
    super.key
  });

  final Quiz quiz;

  @override
  State<_Info> createState() => _InfoState();
}

class _InfoState extends State<_Info> {

  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.quiz.name;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundBody(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TextField(
                controller: nameController,
                autocorrect: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                maxLength: 60,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  widget.quiz.name = value;
                },
              ),
            ),
            const SizedBox(height: 20,),
            _Dates(
              quiz: widget.quiz
            ),
          ],
        ),
      ),
    );
  }
}


class _Dates extends StatefulWidget {
  const _Dates({
    super.key,
    required this.quiz,
  });

  final Quiz quiz;

  @override
  State<_Dates> createState() => _DatesState();
}

class _DatesState extends State<_Dates> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DateTimeItem(
          icon: Icons.arrow_forward,
          text: "Scheduled",
          datetime: widget.quiz.scheduled,
          onDateTimeChanged: (datetime) {
            widget.quiz.scheduled = datetime;
            setState(() {});
          },
        ),
        DateTimeItem(
          icon: Icons.arrow_back,
          text: "End",
          datetime: widget.quiz.end,
          onDateTimeChanged: (datetime) {
            widget.quiz.end = datetime;
            setState(() {});
          },
        ),
      ],
    );
  }
}
