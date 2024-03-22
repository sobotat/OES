

import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CourseHomeworkScreen extends StatelessWidget {
  const CourseHomeworkScreen({
    required this.courseId,
    required this.homeworkId,
    super.key
  });

  final int courseId, homeworkId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
          return FutureBuilder(
            future: HomeworkGateway.instance.get(homeworkId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Toast.makeErrorToast(text: "Failed to load Homework");
                context.goNamed("course", pathParameters: {
                  'course_id': courseId.toString()
                });
              }
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              Homework homework = snapshot.data!;

              return FutureBuilder(
                future: HomeworkGateway.instance.getSubmission(homeworkId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                  List<HomeworkSubmission> submissions = snapshot.data!;
                  print(submissions);

                  return _Body(
                    homework: homework,
                    submissions: submissions,
                    onAddAssigment: () {
                      context.goNamed("submit-course-homework", pathParameters: {
                        "course_id": courseId.toString(),
                        "homework_id": homeworkId.toString()
                      });
                    },
                  );
                }
              );
            },
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.homework,
    required this.submissions,
    required this.onAddAssigment,
    super.key
  });

  final Homework homework;
  final List<HomeworkSubmission> submissions;
  final Function() onAddAssigment;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Heading(
          headingText: homework.name,
          actions: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.add,
                toolTip: "Add Submission",
                maxWidth: 40,
                backgroundColor: Colors.green.shade700,
                onClick: (context) {
                  onAddAssigment();
                },
              ),
            )
          ],
        ),
        BackgroundBody(
          maxHeight: double.infinity,
          child: AppMarkdown(
            data: homework.task,
          ),
        ),
        submissions.isNotEmpty ? ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            HomeworkSubmission submission = submissions[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Heading(headingText: "Submission ${index + 1}",),
                BackgroundBody(
                  maxHeight: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      submission.text != null ? AppMarkdown(data: submission.text!) : Container(),
                      _FilesSubmitted(files: submission.attachments)
                    ],
                  ),
                )
              ],
            );
          },
        ) : Container(
          height: 50,
          alignment: Alignment.center,
          child: const Text("No Submissions", style: TextStyle(fontSize: 16),),
        ),
      ],
    );
  }
}

class _FilesSubmitted extends StatelessWidget {
  const _FilesSubmitted({
    required this.files,
    super.key
  });

  final List<HomeworkSubmissionAttachment> files;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      itemBuilder: (context, index) {
        return _Attachment(attachment: files[index]);
    },);
  }
}

class _Attachment extends StatelessWidget {
  const _Attachment({
    required this.attachment,
    super.key
  });

  final HomeworkSubmissionAttachment attachment;

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: const Icon(Icons.file_copy_outlined),
      body: Text(attachment.fileName),
      actions: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Button(
            icon: Icons.download,
            toolTip: "Download",
            maxWidth: 40,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onClick: (context) async {
              String? path;
              if (kIsWeb) {
                path = attachment.fileName;
              } else {
                path = await FilePicker.platform.getDirectoryPath(dialogTitle: "Download Location");
                if (path == null) return;
                path += "\\${attachment.fileName}";
              }
              debugPrint("Downloading File to $path");

              List<int>? data = await HomeworkGateway.instance.getAttachment(attachment.id);
              if (data == null) return;
              await download(Stream.fromIterable(data), path);
              Toast.makeSuccessToast(text: "File Downloaded", duration: ToastDuration.large);
            },
          ),
        )
      ],
    );
  }
}


