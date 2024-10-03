
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/ui/assets/dialogs/LoadingDialog.dart';
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
import 'package:oes/ui/assets/widgets/questions/editor/PickQuestionEditor.dart';
import 'package:oes/ui/assets/widgets/questions/editor/QuestionEditorFactory.dart';

class CourseTestEditScreen extends StatefulWidget {
  const CourseTestEditScreen({
    required this.courseId,
    required this.testId,
    super.key
  });

  final int courseId;
  final int testId;

  @override
  State<CourseTestEditScreen> createState() => _CourseTestEditScreenState();
}

class _CourseTestEditScreenState extends State<CourseTestEditScreen> {

  bool isNew() { return widget.testId == -1; }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, x) {
          if (!AppSecurity.instance.isInit) return const Material(child: Center(child: WidgetLoading(),),);
          return FutureBuilder(
            future: Future(() async {
              if (!isNew()) {
                return await TestGateway.instance.get(widget.testId);
              }

              return Test(id: -1, name: "", created: DateTime.now(), createdById: AppSecurity.instance.user!.id, scheduled: DateTime.now(), end: DateTime.now(), duration: 0, isVisible: true, maxAttempts: 1, questions: [
                PickOneQuestion(id: -1, name: "Title", description: "Description", points: 0, options: [
                  QuestionOption(id: -1, text: "Option 1", points: 0),
                  QuestionOption(id: -1, text: "Option 2", points: 0),
                  QuestionOption(id: -1, text: "Option 3", points: 0)
                ]),
                PickManyQuestion(id: -1, name: "Title", description: "Description", points: 0, options: [
                  QuestionOption(id: -1, text: "Option 1", points: 0),
                  QuestionOption(id: -1, text: "Option 2", points: 0),
                  QuestionOption(id: -1, text: "Option 3", points: 0)
                ])
              ], password: null);
            },),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Toast.makeErrorToast(text: "Failed to load Test");
                print(snapshot.error);
                context.pop();
              }
              if (!snapshot.hasData) return const Material(child: Center(child: WidgetLoading(),));
              Test test = snapshot.data!;

              return _Body(
                  isNew: isNew(),
                  courseId: widget.courseId,
                  test: test
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
    required this.test,
    super.key
  });

  final bool isNew;
  final int courseId;
  final Test test;

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
        widget.test.questions.add(PickOneQuestion(id: -1, name: "Title", description: "Description", points: 0, options: options));
        break;
      case "pick-many":
        widget.test.questions.add(PickManyQuestion(id: -1, name: "Title", description: "Description", points: 0, options: options));
        break;
      case "open":
        widget.test.questions.add(OpenQuestion(id: -1, name: "Title", description: "Description", points: 0));
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
                    test: widget.test,
                    onUpdated: () {
                      onUpdated();
                    },
                  )
                ),
                Flexible(
                    flex: 1,
                    child: _Preview(
                      test: widget.test,
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
                        test: widget.test,
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
                        test: widget.test,
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
            width: 490,
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
                      _BigIconButton(
                        icon: Icons.open_in_full,
                        text: "Open",
                        onClick: () {
                          onSelectedType('open');
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
      backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
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
    required this.test,
    super.key,
  });

  final Test test;

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
          itemCount: widget.test.questions.length,
          itemBuilder: (context, index) {
            return QuestionBuilderFactory(question: widget.test.questions[index]);
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
    required this.test,
    required this.onUpdated,
    super.key,
  });

  final bool isNew;
  final int courseId;
  final Test test;
  final Function() onUpdated;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {

  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    passwordController.text = widget.test.password ?? "";
  }

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
  }

  Future<void> save() async {
    if (widget.test.name.isEmpty) {
      Toast.makeErrorToast(text: "Name cannot be Empty", duration: ToastDuration.large);
      return;
    }

    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );

    Test? response = widget.isNew ? await TestGateway.instance.create(widget.courseId, widget.test, passwordController.text) :
                                    await TestGateway.instance.update(widget.test, passwordController.text);

    if (response != null) {
      Toast.makeSuccessToast(text: "Test was Saved", duration: ToastDuration.short);
      if (mounted) {
        context.pop();
        context.pop();
      }
      return;
    }

    Toast.makeErrorToast(text: "Failed to Save Test", duration: ToastDuration.large);
    if (mounted) context.pop();
  }

  Future<void> delete() async {
    if(widget.isNew) return;
    bool success = await TestGateway.instance.delete(widget.test.id);
    if (success) {
      Toast.makeSuccessToast(text: "Test was Deleted", duration: ToastDuration.short);
      if (mounted) {
        context.goNamed("course", pathParameters: {
          "course_id": widget.courseId.toString(),
        });
      }
      return;
    }
    Toast.makeErrorToast(text: "Failed to Delete Test", duration: ToastDuration.large);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Heading(
          headingText: widget.isNew ? "Create Test" : "Edit Test",
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
          passwordController: passwordController,
          test: widget.test,
        ),
        const SizedBox(height: 10,),
        const Heading(
          headingText: "Questions",
        ),
        _QuestionsBody(
          test: widget.test,
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
    required this.test,
    required this.onUpdated,
    super.key,
  });

  final Test test;
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
            itemCount: widget.test.questions.length,
            itemBuilder: (context, index) {
              return _QuestionEditor(
                index: index,
                question: widget.test.questions[index],
                onUpdated: (index) {
                  widget.onUpdated();
                },
                onDeleted: (index) {
                  widget.test.questions.removeAt(index);
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

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  String capitalize(String text) {
    return "${text[0].toUpperCase()}${text.substring(1)}";
  }

  @override
  Widget build(BuildContext context) {
    String niceType = widget.question.type.replaceAll('-', ' ').split(' ').map((word) => capitalize(word)).join(' ');
    titleController.text = widget.question.name;
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
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14),
                  ),
                  maxLength: 60,
                  maxLines: 1,
                  onChanged:  (value) {
                    widget.question.name = value;
                    widget.onUpdated(widget.index);
                  },
                ),
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
              QuestionEditorFactory(
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

class _Info extends StatefulWidget {
  const _Info({
    required this.passwordController,
    required this.test,
    super.key
  });
  final TextEditingController passwordController;
  final Test test;

  @override
  State<_Info> createState() => _InfoState();
}

class _InfoState extends State<_Info> {

  TextEditingController nameController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController maxAttemptsController = TextEditingController();
  bool hidden = true;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.test.name;
    durationController.text = widget.test.duration.toString();
    maxAttemptsController.text = widget.test.maxAttempts.toString();
  }

  @override
  void dispose() {
    nameController.dispose();
    durationController.dispose();
    maxAttemptsController.dispose();
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
                  widget.test.name = value;
                },
              ),
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: widget.passwordController,
                    autocorrect: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: hidden,
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Button(
                  icon: hidden ? Icons.remove_red_eye_outlined : Icons.remove_red_eye_rounded,
                  toolTip: hidden ? "Show" : "Hide",
                  maxWidth: 40,
                  onClick: (context) {
                    setState(() {
                      hidden = !hidden;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: durationController,
                    autocorrect: true,
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                      labelText: 'Max Duration (minutes)',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"^([0-9]*)?$"))
                    ],
                    maxLines: 1,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        widget.test.duration = 0;
                        return;
                      }
                      widget.test.duration = int.parse(value);
                    },
                  ),
                ),
                const SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: maxAttemptsController,
                    autocorrect: true,
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                      labelText: 'Max Attempts',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"^([0-9]*)?$"))
                    ],
                    maxLines: 1,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        widget.test.maxAttempts = 0;
                        return;
                      }
                      widget.test.maxAttempts = int.parse(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            _Dates(
              test: widget.test
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
    required this.test,
  });

  final Test test;

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
          datetime: widget.test.scheduled,
          onDateTimeChanged: (datetime) {
            widget.test.scheduled = datetime;
            setState(() {});
          },
        ),
        DateTimeItem(
          icon: Icons.arrow_back,
          text: "End",
          datetime: widget.test.end,
          onDateTimeChanged: (datetime) {
            widget.test.end = datetime;
            setState(() {});
          },
        ),
      ],
    );
  }
}
