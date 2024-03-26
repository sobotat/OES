

import 'dart:math';

import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/Device.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/courseItems/HomeworkGateway.dart';
import 'package:oes/src/services/DeviceInfo.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

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
          if (!AppSecurity.instance.isLoggedIn()) return const Center(child: WidgetLoading(),);
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
                future: Future(() async {
                  Course? course = await CourseGateway.instance.getCourse(courseId);
                  if (course == null) return false;
                  return course.isTeacherInCourse(AppSecurity.instance.user!);
                }),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                  bool isTeacher = snapshot.data!;
                  if (isTeacher) {
                    return FutureBuilder(
                      future: CourseGateway.instance.getCourseStudents(courseId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                        List<User> users = snapshot.data!;
                        return ListView(
                          children: [
                            _TeacherBody(
                              homework: homework,
                              users: users,
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return FutureBuilder(
                    future: HomeworkGateway.instance.getSubmission(homeworkId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
                      List<HomeworkSubmission> submissions = snapshot.data!;
                      return ListView(
                        children: [
                          _StudentBody(
                            homework: homework,
                            courseId: courseId,
                            homeworkId: homeworkId,
                            submissions: submissions
                          ),
                        ],
                      );
                    }
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

class _TeacherBody extends StatefulWidget {
  const _TeacherBody({
    required this.homework,
    required this.users,
    super.key,
  });

  final Homework homework;
  final List<User> users;

  @override
  State<_TeacherBody> createState() => _TeacherBodyState();
}

class _TeacherBodyState extends State<_TeacherBody> {

  TextEditingController pointsController = TextEditingController(text: "0");
  TextEditingController textController = TextEditingController();
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Heading(
          headingText: widget.homework.name,
        ),
        BackgroundBody(
          child: AppMarkdown(
            data: widget.homework.task,
          ),
        ),
        const Heading(
          headingText: "Assignments"
        ),
        BackgroundBody(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.users.length,
            itemBuilder: (context, index) {
              User user = widget.users[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconItem(
                    icon: const Icon(Icons.person),
                    color: Colors.green.shade700,
                    body: Text("${user.firstName} ${user.lastName} (${user.username})"),
                    onClick: (context) async {
                      if (selectedIndex == -1 || selectedIndex != index) {
                        selectedIndex = index;
                      } else {
                        selectedIndex = -1;
                      }

                      setState(() {});
                    },
                  ),
                  selectedIndex == index ? FutureBuilder(
                    future: HomeworkGateway.instance.getUserSubmission(widget.homework.id, user.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        Toast.makeErrorToast(text: "Failed to load User Submissions");
                        print(snapshot.error);
                      }
                      if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: WidgetLoading(),));
                      List<HomeworkSubmission> submission = snapshot.data!;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _Body(
                              submissions: submission,
                              padding: EdgeInsets.zero,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TextField(
                                          controller: textController,
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
                                          data: textController.text,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextField(
                                    controller: pointsController,
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      labelText: "Points",
                                      labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 10,
                                    bottom: 30
                                  ),
                                  child: Button(
                                    text: "Assign Points",
                                    maxWidth: double.infinity,
                                    backgroundColor: Colors.green.shade700,
                                    onClick: (context) {

                                    },
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    }
                  ) : Container(),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}

class _StudentBody extends StatelessWidget {
  const _StudentBody({
    required this.homework,
    required this.courseId,
    required this.homeworkId,
    required this.submissions,
    super.key,
  });

  final Homework homework;
  final int courseId;
  final int homeworkId;
  final List<HomeworkSubmission> submissions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
                  context.goNamed("submit-course-homework", pathParameters: {
                    "course_id": courseId.toString(),
                    "homework_id": homeworkId.toString()
                  });
                },
              ),
            )
          ],
        ),
        BackgroundBody(
          child: AppMarkdown(
            data: homework.task,
          ),
        ),
        _Body( submissions: submissions, ),
      ],
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.submissions,
    this.padding,
    super.key
  });

  final List<HomeworkSubmission> submissions;
  final EdgeInsets? padding;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {

  int index = 0;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        index = widget.submissions.length - 1;
      });
    },);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        widget.submissions.isNotEmpty ? _Submission(
          index: index + 1,
          maxIndex: widget.submissions.length,
          submission: widget.submissions[index],
          padding: widget.padding,
          onPrev: () {
            setState(() {
              index = max(index - 1, 0);
            });
          },
          onNext: () {
            setState(() {
              index = min(index + 1, widget.submissions.length - 1);
            });
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

class _Submission extends StatelessWidget {
  const _Submission({
    required this.index,
    required this.maxIndex,
    required this.submission,
    required this.onPrev,
    required this.onNext,
    this.padding,
    super.key
  });

  final int index;
  final int maxIndex;
  final HomeworkSubmission submission;
  final Function() onPrev;
  final Function() onNext;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Heading(headingText: "Submission",
          padding: padding,
          actions: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.chevron_left,
                toolTip: "Prev",
                maxWidth: 40,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onClick: (context) {
                  onPrev();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text("$index/$maxIndex", style: const TextStyle(fontSize: 16),),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.chevron_right,
                toolTip: "Next",
                maxWidth: 40,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onClick: (context) {
                  onNext();
                },
              ),
            )
          ],
        ),
        BackgroundBody(
          padding: padding,
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

class _Attachment extends StatefulWidget {
  const _Attachment({
    required this.attachment,
    super.key
  });

  final HomeworkSubmissionAttachment attachment;

  @override
  State<_Attachment> createState() => _AttachmentState();
}

class _AttachmentState extends State<_Attachment> {

  int progress = -1;

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: const Icon(Icons.file_copy_outlined),
      body: Text(widget.attachment.fileName),
      actions: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Button(
            icon: progress == -1 ? Icons.download : null,
            text: progress == -1 ? "" : " $progress%",
            toolTip: "Download",
            maxWidth: progress == -1 ? 40 : 100,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onClick: (context) async {
              if (progress != -1) return;
              setState(() {
                progress = 0;
              },);

              Device device = await DeviceInfo.getDevice();
              String? path;
              if (device.isWeb) {
                path = widget.attachment.fileName;
              } else {
                path = await FilePicker.platform.getDirectoryPath(dialogTitle: "Download Location");
                if (path == null) {
                  setState(() {
                    progress = -1;
                  });
                  return;
                }
                path += "/${widget.attachment.fileName}";
              }
              debugPrint("Downloading File to $path");

              List<int>? data = await HomeworkGateway.instance.getAttachment(widget.attachment.id,
                  onProgress: (progress) {
                    setState(() {
                      this.progress = (progress * 100).round();
                    });
                  },).onError((error, stackTrace) {
                debugPrintStack(stackTrace: stackTrace);
                return null;
              });
              if (data == null) {
                setState(() {
                  progress = -1;
                });
                Toast.makeErrorToast(text: "File failed to Download", duration: ToastDuration.large);
                return;
              }

              await download(Stream.fromIterable(data), path);
              Toast.makeSuccessToast(text: "File Downloaded", duration: ToastDuration.large);

              setState(() {
                progress = -1;
              });
            },
          ),
        )
      ],
    );
  }
}


