
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:download/download.dart';
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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

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

  bool isAdding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
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

              return FutureBuilder(
                future: HomeworkGateway.instance.getSubmission(widget.homeworkId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                  List<HomeworkSubmission> submissions = snapshot.data!;
                  print(submissions);

                  if (isAdding) {
                    return _Submit(
                      courseId: widget.courseId,
                      homework: homework,
                      onSubmitted: () {
                        setState(() {
                          isAdding = false;
                        });
                      },
                    );
                  }
                  return _Submitted(
                    homework: homework,
                    submissions: submissions,
                    onAddAssigment: () {
                      setState(() {
                        isAdding = true;
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

class _Submitted extends StatelessWidget {
  const _Submitted({
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


class _Submit extends StatefulWidget {
  const _Submit({
    required this.courseId,
    required this.homework,
    required this.onSubmitted,
    super.key
  });

  final int courseId;
  final Homework homework;
  final Function() onSubmitted;

  @override
  State<_Submit> createState() => _SubmitState();
}

class _SubmitState extends State<_Submit> {

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
            maxHeight: double.infinity,
            child: AppMarkdown(
              data: widget.homework.task,
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
