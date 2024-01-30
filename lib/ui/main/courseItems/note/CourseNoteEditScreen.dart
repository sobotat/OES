
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Note.dart';
import 'package:oes/src/restApi/interface/courseItems/NoteGateway.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseNoteEditScreen extends StatelessWidget {
  const CourseNoteEditScreen({
    required this.courseId,
    required this.noteId,
    super.key
  });

  final int courseId;
  final int noteId;

  bool isNew() { return noteId == -1; }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSecurity.instance,
      builder: (context, child) {
        if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading());
        return FutureBuilder(
          future: Future(() async {
            if (!isNew()) {
              return await NoteGateway.instance.get(courseId, noteId);
            }
            return Note(
                id: -1,
                name:'Title',
                created: DateTime.now(),
                createdById: AppSecurity.instance.user!.id,
                isVisible: true,
                data: """          
- First
- Second
- Third
                   
Some **more** *text*
              
## Types    
1. Vars
2. Functions
3. Classes

> some info

---
### Code
```java
public static void main(String args[]) {  
  System.out.println("Hello World");  
}
```
```bash
  ./something
```
---

# Image
![Image](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfjL9xNhvpuUtKH9v-a1X_FD0BRg7lrFBTIo0Fz7reTywPZwVMRVkYrzVp1q0v-BlVrnw&usqp=CAU)

                """
            );
          }),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              Toast.makeErrorToast(text: "Failed to load Notes");
              context.pop();
            }
            if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
            Note note = snapshot.data!;

            return _Body(
              courseId: courseId,
              note: note,
            );
          },
        );
      },
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.courseId,
    required this.note,
    super.key
  });

  final int courseId;
  final Note note;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 500;

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
                    courseId: widget.courseId,
                    note: widget.note,
                    onUpdated: (updatedNote) {
                      setState(() {});
                    },
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: _Preview(note: widget.note),
                )
              ],
            )
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
                      courseId: widget.courseId,
                      note: widget.note,
                      onUpdated: (updatedNote) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    _Preview(note: widget.note),
                  ],
                )
              ]
            ),
          ),
        ],
      ),
    );
  }
}


class _Editor extends StatefulWidget {
  const _Editor({
    required this.courseId,
    required this.note,
    required this.onUpdated,
    super.key,
  });

  final int courseId;
  final Note note;
  final Function(Note note) onUpdated;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {

  TextEditingController editorController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    Future(() {
      setState(() {
        editorController.text = widget.note.data;
        nameController.text = widget.note.name;
        isVisible = widget.note.isVisible;
      });
    },);
  }

  @override
  void dispose() {
    editorController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    widget.note.isVisible = isVisible;
    widget.note.name = nameController.text;
    widget.note.data = editorController.text;

    Note? response = isNew() ? await NoteGateway.instance.create(widget.courseId, widget.note) :
                               await NoteGateway.instance.update(widget.courseId, widget.note);

    if (response != null) {
      Toast.makeSuccessToast(text: "Note was Saved", duration: ToastDuration.short);
      if (mounted) context.pop();
      return;
    }

    Toast.makeErrorToast(text: "Failed to Save Note", duration: ToastDuration.large);
  }

  Future<void> delete() async {
    bool success = await NoteGateway.instance.delete(widget.courseId, widget.note.id);
    if (success) {
      Toast.makeSuccessToast(text: "Note was Deleted", duration: ToastDuration.short);
      if (mounted) {
        context.goNamed('course', pathParameters: {
          'course_id': widget.courseId.toString(),
        });
      }
      return;
    }
    Toast.makeErrorToast(text: "Failed to Delete Note", duration: ToastDuration.large);
  }

  bool isNew() { return widget.note.id == -1; }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Heading(
          headingText: 'Info',
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
            !isNew() ? Padding(
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
                    widget.note.name = value;
                    widget.onUpdated(widget.note);
                  },
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Is Visible",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Checkbox(
                      value: isVisible,
                      onChanged: (value) {
                        setState(() {
                          isVisible = value ?? isVisible;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        const Heading(headingText: 'Editor'),
        BackgroundBody(
          maxHeight: double.infinity,
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
                widget.note.data = value;
                widget.onUpdated(widget.note);
              },
            ),
          ),
        )
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    super.key,
    required this.note,
  });

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
}
