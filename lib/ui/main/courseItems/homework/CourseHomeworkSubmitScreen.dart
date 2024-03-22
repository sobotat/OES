
import 'dart:io';

import 'package:dio/dio.dart';
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

class CourseHomeworkSubmitScreen extends StatelessWidget {
  const CourseHomeworkSubmitScreen({
    required this.courseId,
    required this.homeworkId,
    super.key
  });

  final int courseId;
  final int homeworkId;

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

              return _Body(
                courseId: courseId,
                homework: homework,
                onSubmitted: () {
                  context.pop();
                },
              );
            },
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
    required this.onSubmitted,
    super.key
  });

  final int courseId;
  final Homework homework;
  final Function() onSubmitted;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {

  TextEditingController editorController = TextEditingController();
  GlobalKey<_FilesState> key = GlobalKey();
  int progress = -1;
  bool failedUpload = false;

  @override
  void dispose() {
    editorController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      progress = 0;
      failedUpload = false;
    });
    List<MultipartFile> files = key.currentState?.getFiles() ?? [];
    bool success = await HomeworkGateway.instance.submit(widget.homework.id, editorController.text, files,
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
      progress = 101;
      Future.delayed(const Duration(seconds: 1), () {
        widget.onSubmitted();
      },);
    } else {
      Toast.makeErrorToast(text: "Failed to Upload File");
      progress = -1;
      failedUpload = true;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: [
          Heading(
            headingText: widget.homework.name,
            actions: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Button(
                  icon: progress == -1 && !failedUpload ? Icons.done_all : null,
                  text: progress == -1 ? !failedUpload ? "" : "Failed" : progress == 101 ? "Uploaded" : "${progress.round()}%",
                  toolTip: "Submit",
                  maxWidth: progress == -1 && !failedUpload ? 40 : 100,
                  backgroundColor: !failedUpload ? Colors.green.shade700 : Colors.red.shade700,
                  onClick: (context) {
                    if (progress == -1 || progress == 101) submit();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Button(
                  icon: Icons.arrow_back,
                  toolTip: "Back",
                  maxWidth: 40,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  onClick: (context) {
                    widget.onSubmitted();
                  },
                ),
              ),
            ],
          ),
          BackgroundBody(
            child: AppMarkdown(
              data: widget.homework.task,
            ),
          ),
          const Heading(headingText: "Text"),
          BackgroundBody(
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
              child: _Files(
                homeworkId: widget.homework.id,
                key: key,
              )
          ),
        ]
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      for(PlatformFile file in result.files) {
        debugPrint("Filename: ${file.name}, Size: ${file.size}");
        if (file.size >= 1000000000) {
          Toast.makeErrorToast(text: "File is too large");
          continue;
        }

        onSelected(file);
      }
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
