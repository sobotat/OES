
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

class CourseHomeworkScreen extends StatefulWidget {
  const CourseHomeworkScreen({
    required this.courseId,
    required this.homeworkId,
    super.key
  });

  final int courseId, homeworkId;

  @override
  State<CourseHomeworkScreen> createState() => _CourseHomeworkScreenState();
}

class _CourseHomeworkScreenState extends State<CourseHomeworkScreen> {

  TextEditingController editorController = TextEditingController();
  PlatformFile? file;
  String status = "No File";
  int progress = 0;

  @override
  void dispose() {
    editorController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      status = "Sending";
    });
    bool success = await HomeworkGateway.instance.submit(editorController.text, file != null ? MultipartFile.fromBytes(file!.bytes as List<int>, filename: file!.name) : null,
      onProgress: (progress) {
        setState(() {
          this.progress = (progress * 100).round();
        });
      },)
      .onError((error, stackTrace) {
        if (error is RangeError) Toast.makeErrorToast(text: "File is too large");
        throw error!;
      }
    );
    if (success) {
      Toast.makeSuccessToast(text: "File was Uploaded");
      setState(() {
        status = "Uploaded";
      });
    } else {
      Toast.makeErrorToast(text: "Failed to Upload File");
      setState(() {
        status = "Failed";
      });
    }
  }

  String getFileProgressText() {
    if (status == "Sending") return "$progress %";
    return status;
  }

  Color getFileProgressColor() {
    switch(status) {
      case "Uploaded": return Colors.green.shade700;
      case "Sending": return Colors.greenAccent.shade700;
      case "Ready": return Colors.orange.shade700;
    }
    return Colors.red.shade700;
  }

  Future<void> _sendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      debugPrint("Filename: ${file.name}, Size: ${file.size}");
      if (file.size >= 1000000000) {
        Toast.makeErrorToast(text: "File is too large");
      }

      setState(() {
        status = "Ready";
        this.file = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          return FutureBuilder(
            future: Future(() {
              return Homework(
                id: -1,
                created: DateTime.now().subtract(const Duration(days: 30)),
                createdById: 1,
                text: "AAAAAAAaaaaaaaaaaaaaaaaaaa",
                task: """Write how to make this 
```bash
  ./run_hack
```
                """,
                fileName: null,
                isVisible: true,
                end: DateTime.now().add(const Duration(days: 10)),
                name: "HW 1",
                scheduled: DateTime.now().subtract(const Duration(days: 1))
              );
            }),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              Homework homework = snapshot.data!;
              editorController.text = homework.text;

              return ListView(
                children: [
                  Heading(
                    headingText: homework.name,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Button(
                          icon: Icons.done_all,
                          toolTip: "Submit",
                          maxWidth: 40,
                          backgroundColor: Colors.green.shade700,
                          onClick: (context) {
                            submit();
                          },
                        ),
                      ),
                    ],
                  ),
                  BackgroundBody(
                    maxHeight: double.infinity,
                    child: AppMarkdown(
                      data: homework.task,
                    ),
                  ),
                  const Heading(headingText: "Text"),
                  BackgroundBody(
                    maxHeight: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextField(
                              controller: editorController,
                              autocorrect: true,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              style: const TextStyle(
                                  fontSize: 14
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: AppMarkdown(
                              data: editorController.text,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Heading(headingText: "File"),
                  BackgroundBody(
                    maxHeight: double.infinity,
                    child: file == null ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Button(
                        text: "Upload",
                        onClick: (context) async {
                          await _sendFile();
                        },
                      ),
                    ) : IconItem(
                      icon: Text(getFileProgressText()),
                      width: 100,
                      color: getFileProgressColor(),
                      body: Text(file?.name ?? "No File")
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
