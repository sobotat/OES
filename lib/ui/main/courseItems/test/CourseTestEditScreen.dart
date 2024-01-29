
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/objects/questions/PickOneQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilderFactory.dart';

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

  Test test = Test(id: -1, name: "", created: DateTime.now(), createdById: AppSecurity.instance.user!.id, scheduled: DateTime.now(), end: DateTime.now(), duration: 0, isVisible: true, maxAttempts: 1);

  TextEditingController nameController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController maxAttemptsController = TextEditingController();

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      if (!isNewTest()) {
        test = await TestGateway.instance.get(widget.courseId, widget.testId) ?? test;
      }
      nameController.text = test.name;
      durationController.text = test.duration.toString();
      maxAttemptsController.text = test.maxAttempts.toString();

      isInit = true;
      setState(() {});
    },);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    durationController.dispose();
    maxAttemptsController.dispose();
  }

  Future<void> save() async {

    if (nameController.text.isEmpty) {
      Toast.makeErrorToast(text: "Name cannot be Empty", duration: ToastDuration.large);
      return;
    }
    test.name = nameController.text;
    
    Test? response = await TestGateway.instance.create(widget.courseId, test);
    if (response != null) {
      Toast.makeSuccessToast(text: "Test was Saved", duration: ToastDuration.short);
      context.pop();
      return;
    }

    Toast.makeErrorToast(text: "Failed to Save Test", duration: ToastDuration.large);
  }

  Future<void> delete() async {
    if(isNewTest()) return;
    bool success = await TestGateway.instance.delete(widget.courseId, widget.testId);
    if (success) {
      Toast.makeSuccessToast(text: "Test was Deleted", duration: ToastDuration.short);
      context.pop();
      return;
    }
    Toast.makeErrorToast(text: "Failed to Delete Test", duration: ToastDuration.large);
  }

  bool isNewTest() { return widget.testId == -1; }

  void addQuestion(int index, String questionType) {
    List<Question> questions = [];
    for(int i = 0; i < index; i++) {
      questions.add(test.questions[i]);
    }

    switch(questionType) {
      case "pick-one":
        questions.add(PickOneQuestion(id: -1, title: "Title", description: "Description", points: 0, options: [QuestionOption(id: -1, text: "hi", points: 3)]));
        break;
      default:
        print("Add Question Failed -> Type [$questionType] is Not Supported");
        return;
    }

    for(int i = index; i < test.questions.length; i++) {
      questions.add(test.questions[i]);
    }

    setState(() {
      test.questions = questions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: Builder(
        builder: (context) {
          if (!isInit) return const Center(child: WidgetLoading(),);
          return ListView(
            children: [
              Heading(
                headingText: isNewTest() ? "Create Test" : "Edit Test",
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
                  !isNewTest() ? Padding(
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
              BackgroundBody(
                maxHeight: double.infinity,
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
                        ),
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
                                labelText: 'Max Duration (seconds)',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLines: 1,
                              onChanged: (value) {
                                if(value.isEmpty) durationController.text = "0";
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
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLines: 1,
                              onChanged: (value) {
                                if(value.isEmpty) maxAttemptsController.text = "0";
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      _Dates(test: test)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              const Heading(headingText: "Questions"),
              Text("Not Final Version !!!", style: TextStyle(color: Colors.red.shade700, fontSize: 30),),
              BackgroundBody(
                maxHeight: double.infinity,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: test.questions.length + 1,
                  itemBuilder: (context, index) {
                    if(test.questions.length == index) {
                      return Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: HeadingLine(),
                          ),
                          _AddQuestionButton(
                            onQuestionSelected: (questionType) {
                              addQuestion(index, questionType);
                            },
                          ),
                        ],
                      );
                    }
                    Question question = test.questions[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        index != 0 ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: HeadingLine(),
                        ) : const SizedBox(height: 20,),
                        _AddQuestionButton(
                          onQuestionSelected: (questionType) {
                            addQuestion(index, questionType);
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: HeadingLine(),
                        ),
                        QuestionBuilderFactory(
                          question: question, edit: true
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _AddQuestionButton extends StatelessWidget {
  const _AddQuestionButton({
    required this.onQuestionSelected,
    super.key
  });

  final Function(String questionType) onQuestionSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Button(
        icon: Icons.add,
        text: "Add Question",
        backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
        maxWidth: double.infinity,
        onClick: (context) {
          onQuestionSelected("pick-one");
        },
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

  Future<DateTime?> pickDateTime(DateTime dateTime) async {
    DateTime? date = await showDialog(context: context, builder: (context) => DatePickerDialog(
      firstDate: DateTime.utc(2000),
      lastDate: DateTime.utc(3000),
      initialDate: dateTime,));
    if (date == null) return null;

    TimeOfDay? time = await showDialog(context: context, builder: (context) => TimePickerDialog(
      initialTime: TimeOfDay.fromDateTime(dateTime),));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour}:${widget.test.end.minute < 10 ? "0" : ""}${dateTime.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconItem(
          icon: const Icon(Icons.arrow_forward),
          body: Row(
            children: [
              Text("Scheduled: ".padRight(15), style: const TextStyle(fontWeight: FontWeight.bold),),
              Text(formatDateTime(widget.test.scheduled)),
            ],
          ),
          onClick: (context) {
            pickDateTime(widget.test.end).then((value) {
              if (value == null) return;
              widget.test.scheduled = value;
              setState(() {});
            });
          },
        ),
        IconItem(
          icon: const Icon(Icons.arrow_back),
          body: Row(
            children: [
              Text("End: ".padRight(22), style: const TextStyle(fontWeight: FontWeight.bold),),
              Text(formatDateTime(widget.test.end)),
            ],
          ),
          onClick: (context) {
            pickDateTime(widget.test.end).then((value) {
              if (value == null) return;
              widget.test.end = value;
              setState(() {});
            });
          },
        ),
      ],
    );
  }
}
