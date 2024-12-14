
import 'dart:async';
import 'dart:convert';

import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/SharePermission.dart';
import 'package:oes/src/objects/courseItems/UserQuiz.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/restApi/interface/courseItems/UserQuizGateway.dart';
import 'package:oes/src/restApi/interface/courseItems/UserQuizShareGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/ui/assets/buttons/ShareButton.dart';
import 'package:oes/ui/assets/dialogs/LoadingDialog.dart';
import 'package:oes/ui/assets/dialogs/ShareDialog.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilderFactory.dart';
import 'package:oes/ui/assets/widgets/questions/editor/QuestionEditorFactory.dart';

class CourseUserQuizEditScreen extends StatefulWidget {
  const CourseUserQuizEditScreen({
    required this.courseId,
    required this.quizId,
    super.key
  });

  final int courseId;
  final int quizId;

  @override
  State<CourseUserQuizEditScreen> createState() => _CourseUserQuizEditScreenState();
}

class _CourseUserQuizEditScreenState extends State<CourseUserQuizEditScreen> {

  bool isNew() { return widget.quizId == -1; }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, x) {
          if (!AppSecurity.instance.isInit) return const Material(child: Center(child: WidgetLoading(),),);
          return FutureBuilder(
            future: Future(() async {
              if (isNew()) return SharePermission.editor;
              return await UserQuizShareGateway.instance.getPermission(widget.quizId, AppSecurity.instance.user!.id);
            }),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Material(child: Center(child: WidgetLoading(),));
              if (snapshot.data! != SharePermission.editor) {
                  return Material(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("You are not Editor", style: TextStyle(fontSize: 30),),
                        Button(
                          text: "Back",
                          onClick: (context) {
                            context.pop();
                          },
                        )
                      ],
                    ),
                  ),
                );
              }

              return FutureBuilder(
                future: Future(() async {
                  if (!isNew()) {
                    return await UserQuizGateway.instance.get(widget.quizId);
                  }

                  return UserQuiz(id: -1, name: "", created: DateTime.now(), createdById: AppSecurity.instance.user!.id, isVisible: true, questions: [
                    PickOneQuestion(id: 1, name: "Pick One", description: "Description", points: 0, options: [
                      QuestionOption(id: -1, text: "Option 1", points: 0),
                      QuestionOption(id: -1, text: "Option 2", points: 0),
                      QuestionOption(id: -1, text: "Option 3", points: 0)
                    ]),
                    PickManyQuestion(id: 2, name: "Pick Many", description: "Description", points: 0, options: [
                      QuestionOption(id: -1, text: "Option 1", points: 0),
                      QuestionOption(id: -1, text: "Option 2", points: 0),
                      QuestionOption(id: -1, text: "Option 3", points: 0)
                    ])
                  ],);
                },),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    Toast.makeErrorToast(text: "Failed to load UserQuiz");
                    print(snapshot.error);
                    context.pop();
                  }
                  if (!snapshot.hasData) return const Material(child: Center(child: WidgetLoading(),));
                  UserQuiz quiz = snapshot.data!;

                  return _Body(
                      isNew: isNew(),
                      courseId: widget.courseId,
                      quiz: quiz,
                  );
                },
              );
            }
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
  final UserQuiz quiz;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {

  late TabController tabController;
  Timer updateTimer = Timer(const Duration(seconds: 1), () { });
  GlobalKey<_PreviewState> previewKey = GlobalKey<_PreviewState>();
  GlobalKey<_EditorState> editorKey = GlobalKey<_EditorState>();

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
      QuestionOption(id: 1, text: "Option 1", points: 0),
      QuestionOption(id: 2, text: "Option 2", points: 0),
      QuestionOption(id: 3, text: "Option 3", points: 0)
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
      previewState.setState(() {});
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
        floatingActionButton: Column(
          children: [
            _SaveFloatingButton(
              saveMethod: () {
                editorKey.currentState?.save();
              },
            ),
            const SizedBox(height: 10,),
            _AddButton(
              onSelectedType: (type) {
                addQuestion(type);
              },
            ),
          ],
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
                        key: editorKey,
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SaveFloatingButton(
            saveMethod: () {
              editorKey.currentState?.save();
            },
          ),
          const SizedBox(height: 10,),
          _AddButton(
            onSelectedType: (type) {
              addQuestion(type);
            },
          ),
        ],
      ),
    );
  }
}

class _SaveFloatingButton extends StatelessWidget {
  const _SaveFloatingButton({
    required this.saveMethod,
    super.key
  });

  final Function() saveMethod;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'save',
      tooltip: 'Save',
      backgroundColor: Colors.green.shade400,
      child: const Icon(
        Icons.save,
        color: Colors.white,
      ),
      onPressed: () {
        saveMethod();
      },
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
      backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
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

  final UserQuiz quiz;

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
  final UserQuiz quiz;
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

    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );

    UserQuiz? response = widget.isNew ? await UserQuizGateway.instance.create(widget.courseId, widget.quiz) :
                                    await UserQuizGateway.instance.update(widget.quiz);

    if (response != null) {
      Toast.makeSuccessToast(text: "UserQuiz was Saved", duration: ToastDuration.short);
      if (mounted) context.pop();
      return;
    }

    Toast.makeErrorToast(text: "Failed to Save UserQuiz", duration: ToastDuration.large);
    if (mounted) context.pop();
  }

  Future<void> delete() async {
    if(widget.isNew) return;
    bool success = await UserQuizGateway.instance.delete(widget.quiz.id);
    if (success) {
      Toast.makeSuccessToast(text: "UserQuiz was Deleted", duration: ToastDuration.short);
      if (mounted) {
        context.goNamed("course", pathParameters: {
          "course_id": widget.courseId.toString(),
        });
      }
      return;
    }
    Toast.makeErrorToast(text: "Failed to Delete UserQuiz", duration: ToastDuration.large);
  }

  Future<void> export() async {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );

    Device device = await DeviceInfo.getDevice();
    String fileName = "${widget.quiz.name}_${DateTime.now()}.json";
    String? path;
    if (device.isWeb) {
      path = fileName;
    } else {
      path = await FilePicker.platform.getDirectoryPath(dialogTitle: "Download Location");
      if (path == null) {
        if(mounted) context.pop();
        return;
      }
      path += "/$fileName";
    }
    debugPrint("Downloading File to $path");

    String json = jsonEncode(widget.quiz.toMap());
    List<int> data = utf8.encode(json);
    download(Stream.fromIterable(data), path);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Heading(
          headingText: widget.isNew ? "Create UserQuiz" : "Edit UserQuiz",
          actions: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.download,
                toolTip: "Export",
                maxWidth: 40,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onClick: (context) {
                  export();
                },
              ),
            ),
            !widget.isNew ? ShareButton(
              courseId: widget.courseId,
              itemId: widget.quiz.id,
              gateway: UserQuizShareGateway.instance,
            ) : Container(),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.save,
                toolTip: "Save",
                maxWidth: 40,
                backgroundColor: Colors.green.shade400,
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

  final UserQuiz quiz;
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
              QuestionEditorFactory(
                question: widget.question,
                allowSwitchForPoints: true,
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
    required this.quiz,
    super.key
  });

  final UserQuiz quiz;

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
          ],
        ),
      ),
    );
  }
}
