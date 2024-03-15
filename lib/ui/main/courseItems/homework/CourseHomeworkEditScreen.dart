
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/restApi/interface/courseItems/HomeworkGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/DateTimeItem.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseHomeworkEditScreen extends StatelessWidget {
  const CourseHomeworkEditScreen({
    required this.courseId,
    required this.homeworkId,
    super.key
  });

  final int courseId;
  final int homeworkId;

  bool isNew() { return homeworkId == -1; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading());
          return FutureBuilder(
            future: Future(() async {
              if (!isNew()) {
                return await HomeworkGateway.instance.get(homeworkId);
              }
              return Homework(
                  id: -1,
                  name:'Homework Name',
                  created: DateTime.now(),
                  createdById: AppSecurity.instance.user!.id,
                  isVisible: true,
                  scheduled: DateTime.now(),
                  end: DateTime.now().add(const Duration(days: 1)),
                  task: "1.How to write code\n2.How to draw clouds"
              );
            }),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Toast.makeErrorToast(text: "Failed to load Homework");
                context.pop();
              }
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              Homework homework = snapshot.data!;
              return _Body(
                courseId: courseId,
                homework: homework,
                isNew: isNew(),
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
    required this.courseId,
    required this.homework,
    required this.isNew,
    super.key
  });

  final int courseId;
  final Homework homework;
  final bool isNew;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {

  TextEditingController nameController = TextEditingController();
  TextEditingController taskController = TextEditingController();
  GlobalKey<_PreviewState> key = GlobalKey();

  Future<void> save() async {
    Homework? response = widget.isNew ? await HomeworkGateway.instance.create(widget.courseId, widget.homework) :
                                        await HomeworkGateway.instance.update(widget.homework);

    if (response != null) {
      Toast.makeSuccessToast(text: "Homework was Saved", duration: ToastDuration.short);
      if (mounted) context.pop();
      return;
    }

    Toast.makeErrorToast(text: "Failed to Save Homework", duration: ToastDuration.large);
  }

  Future<void> delete() async {
    bool success = await HomeworkGateway.instance.delete(widget.homework.id);
    if (success) {
      Toast.makeSuccessToast(text: "Homework was Deleted", duration: ToastDuration.short);
      if (mounted) {
        context.goNamed('course', pathParameters: {
          'course_id': widget.courseId.toString(),
        });
      }
      return;
    }
    Toast.makeErrorToast(text: "Failed to Delete Homework", duration: ToastDuration.large);
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = widget.homework.name;
    taskController.text = widget.homework.task;

    return ListView(
      children: [
        Heading(
          headingText: "Info",
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
            ]
        ),
        BackgroundBody(
          maxHeight: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  maxLength: 30,
                  style: const TextStyle(
                      fontSize: 14
                  ),
                  decoration: const InputDecoration(
                    labelText: "Name",
                  ),
                  onChanged: (value) {
                    widget.homework.name = value;
                    key.currentState?.setState(() {});
                  },
                ),
                TextField(
                  controller: taskController,
                  autocorrect: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: const TextStyle(
                      fontSize: 14
                  ),
                  decoration: const InputDecoration(
                    labelText: "Task",
                  ),
                  onChanged: (value) {
                    widget.homework.task = value;
                    key.currentState?.setState(() {});
                  },
                ),
                const SizedBox(height: 10,),
                _Dates(
                  homework: widget.homework
                ),
              ],
            ),
          ),
        ),
        const Heading(headingText: "Preview"),
        BackgroundBody(
          maxHeight: double.infinity,
          child: _Preview(
            homework: widget.homework,
            key: key,
          ),
        )
      ],
    );
  }
}

class _Dates extends StatefulWidget {
  const _Dates({
    required this.homework,
    super.key
  });

  final Homework homework;

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
          datetime: widget.homework.scheduled,
          onDateTimeChanged: (datetime) {
            widget.homework.scheduled = datetime;
            setState(() {});
          },
        ),
        DateTimeItem(
          icon: Icons.arrow_back,
          text: "End",
          datetime: widget.homework.end,
          onDateTimeChanged: (datetime) {
            widget.homework.end = datetime;
            setState(() {});
          },
        ),
      ],
    );
  }
}

class _Preview extends StatefulWidget {
  const _Preview({
    required this.homework,
    super.key
  });

  final Homework homework;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  @override
  Widget build(BuildContext context) {
    return AppMarkdown(data: widget.homework.task);
  }
}
