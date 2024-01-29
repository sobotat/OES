

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Note.dart';
import 'package:oes/src/restApi/interface/courseItems/NoteGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseNoteScreen extends StatelessWidget {
  const CourseNoteScreen({
    required this.courseId,
    required this.noteId,
    super.key
  });

  final int courseId;
  final int noteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, x) {
          if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
          return FutureBuilder(
            future: NoteGateway.instance.get(courseId, noteId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Toast.makeErrorToast(text: "Failed to load Notes");
                context.pop();
              }
              if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
              Note note = snapshot.data!;

              return ListView(
                children: [
                  Heading(headingText: note.name),
                  BackgroundBody(
                    maxHeight: double.infinity,
                    child: AppMarkdown(
                      data: note.data,
                      flipBlocksColors: true,
                    ),
                  )
                ],
              );
            }
          );
        }
      ),
    );
  }
}
