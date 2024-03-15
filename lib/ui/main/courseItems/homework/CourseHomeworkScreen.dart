
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
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
  GlobalKey<_FilesState> key = GlobalKey();
  int progress = 0;

  @override
  void dispose() {
    editorController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    List<MultipartFile> files = key.currentState?.getFiles() ?? [];
    bool success = await HomeworkGateway.instance.submit(widget.homeworkId, "", files,
      onProgress: (progress) {
        setState(() {
          this.progress = (progress * 100).round();
        });
      },)
        .onError((error, stackTrace) {
      if (error is RangeError) Toast.makeErrorToast(text: "File is too large");
      progress = 0;
      print("Submit Error: $error");
      return false;
    }
    );
    if (success) {
      Toast.makeSuccessToast(text: "File was Uploaded");
      progress = 100;
    } else {
      Toast.makeErrorToast(text: "Failed to Upload File");
      progress = 0;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          return FutureBuilder(
            future: HomeworkGateway.instance.get(widget.homeworkId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Toast.makeErrorToast(text: "Failed to load Homework");
                context.goNamed("course", pathParameters: {
                  'course_id': widget.courseId.toString()
                });
              }
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              Homework homework = snapshot.data!;

              return ListView(
                children: [
                  Heading(
                    headingText: homework.name,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Button(
                          icon: progress == 0 ? Icons.done_all : null,
                          text: progress == 0 ? "" : progress == 100 ? "Uploaded" : "${progress.round()}%",
                          toolTip: "Submit",
                          maxWidth: progress == 0 ? 40 : 100,
                          backgroundColor: Colors.green.shade700,
                          onClick: (context) {
                            if (progress == 0 || progress == 100) submit();
                          },
                        ),
                      ),
                      FutureBuilder<bool>(
                          future: Future(() async {
                            Course? course = await CourseGateway.instance.getCourse(widget.courseId);
                            return await course?.isTeacherInCourse(AppSecurity.instance.user!) ?? false;
                          }),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();
                            bool isTeacher = snapshot.data!;
                            if (!isTeacher) return Container();
                            return Padding(
                              padding: const EdgeInsets.all(5),
                              child: Button(
                                icon: Icons.edit,
                                toolTip: "Edit",
                                maxWidth: 40,
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                onClick: (context) {
                                  context.goNamed('edit-course-homework', pathParameters: {
                                    'course_id': widget.courseId.toString(),
                                    'homework_id': widget.homeworkId.toString(),
                                  });
                                },
                              ),
                            );
                          }
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
                    child: _Files(
                      homeworkId: widget.homeworkId,
                      key: key,
                    )
                  ),
                ]
              );
            },
          );
        },
      ),
    );
  }
}

class _Files extends StatefulWidget {
  const _Files({
    required this.homeworkId,
    super.key
  });

  final int homeworkId;

  @override
  State<_Files> createState() => _FilesState();
}

class _FilesState extends State<_Files> {

  List<PlatformFile> files = [];

  List<MultipartFile> getFiles() {
    List<MultipartFile> multiFiles = [];
    for (PlatformFile file in files) {
      List<int> bytes = [];
      if (file.bytes != null) {
        bytes = file.bytes as List<int>;
      } else {
        File f = File(file.path.toString());
        bytes = f.readAsBytesSync();
      }
      multiFiles.add(MultipartFile.fromBytes(bytes, filename: file.name));
    }
    return multiFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: files.length,
          itemBuilder: (context, index) {
            return _FileItem(
              file: files[index],
              onRemove: (file) {
                setState(() {
                  files.remove(file);
                });
              },
            );
          },
        ),
        _SelectFile(onSelected: (file) {
          setState(() {
            files.add(file);
          });
        },)
      ],
    );
  }
}

class _SelectFile extends StatelessWidget {
  const _SelectFile({
    required this.onSelected,
    super.key
  });

  final Function(PlatformFile file) onSelected;

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      debugPrint("Filename: ${file.name}, Size: ${file.size}");
      if (file.size >= 1000000000) {
        Toast.makeErrorToast(text: "File is too large");
      }

      onSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Button(
        text: "Upload",
        maxWidth: double.infinity,
        onClick: (context) async {
          await selectFile();
        },
      ),
    );
  }
}



class _FileItem extends StatelessWidget {
  const _FileItem({
    required this.file,
    required this.onRemove,
    super.key
  });

  final PlatformFile file;
  final Function(PlatformFile file) onRemove;

  void remove() {
    onRemove(file);
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: const Icon(Icons.file_copy_outlined),
      body: Text(file.name),
      actions: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Button(
            icon: Icons.close,
            toolTip: "Remove",
            maxWidth: 40,
            backgroundColor: Colors.red.shade700,
            onClick: (context) {
              remove();
            },
          ),
        )
      ],
    );
  }
}
