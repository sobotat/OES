import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/services/NewTabOpener.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/RefreshWidget.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  GlobalKey<RefreshWidgetState> refreshKey = GlobalKey<RefreshWidgetState>();
  GlobalKey<_CoursesState> courseKey = GlobalKey<_CoursesState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        actions: kIsWeb ? ([
          const _BackToWeb(),
        ]) : [],
        onRefresh: () {
          refreshKey.currentState?.refresh();
        },
      ),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, x) {
          if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
          return RefreshWidget(
            key: refreshKey,
            onRefreshed: () {
              setState(() {});
              if (courseKey.currentState?.mounted ?? false) {
                courseKey.currentState?.setState(() {});
              }
            },
            child: ListView(
              children: [
                _Courses(
                  key: courseKey,
                ),
              ],
            ),
          );
        }
      ),
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       heroTag: '3',
      //       onPressed: () {
      //         context.goNamed('test');
      //       },
      //       child: const Icon(AppIcons.icon_darkmode),
      //     ),
      //   ],
      // ),
    );
  }
}

class _BackToWeb extends StatelessWidget {
  const _BackToWeb({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    if (width <= overflow) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        child: Button(
          text: 'To Web',
          onClick: (context) {
            context.goNamed('/');
          },
          onMiddleClick: (context) {
            NewTabOpener.open(context.namedLocation("/"));
          },
        ),
      );
    }

    return SizedBox(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        child: Button(
          icon: AppIcons.icon_web,
          iconSize: 18,
          onClick: (context) {
            context.goNamed('/');
          },
        ),
      ),
    );
  }
}

class _Courses extends StatefulWidget {
  const _Courses({
    super.key,
  });

  @override
  State<_Courses> createState() => _CoursesState();
}

class _CoursesState extends State<_Courses> {

  Future<void> joinCourse() async {
    bool success = await showDialog<bool>(
      context: context, 
      builder: (context) {
        return const _JoinDialog();
      }
    ) ?? false;

    if (mounted && success) {
      setState(() {});
    }
  }

  void createCourse() async {
    await showDialog(
      context: context,
      builder: (context) => const PopupDialog(child: _CourseCreateDialog()),
    );

    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(!AppSecurity.instance.isLoggedIn()) return const Center(child: WidgetLoading(),);
    User user = AppSecurity.instance.user!;
    UserRole role = user.role ?? UserRole.student;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Heading(
          headingText: 'Courses:',
          actions: role != UserRole.student ? [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.add,
                toolTip: "Create",
                maxWidth: 40,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onClick: (context) => createCourse(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                icon: Icons.edit,
                toolTip: "Join",
                maxWidth: 40,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onClick: (context) => joinCourse(),
              ),
            ),
          ] : [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                text: "Join",
                maxWidth: 75,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onClick: (context) => joinCourse(),
              ),
            ),
          ],
        ),
        BackgroundBody(
          child: FutureBuilder(
            future: CourseGateway.instance.getUserCourses(user),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Toast.makeErrorToast(text: "Failed to load User Courses");
              }
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: WidgetLoading(),)
                );
              }
              List<Course> courses = snapshot.data!;
              return ListView.builder(
                itemCount: courses.length,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 5),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: courses[index].isTeacherInCourse(AppSecurity.instance.user!),
                    builder: (context, snapshot) {
                      return _CourseItem(
                        course: courses[index],
                        height: 50,
                        role: role,
                        isUserTeacher: snapshot.data ?? false
                      );
                    },
                  );
                },
              );
            }
          ),
        )
      ],
    );
  }
}

class _JoinDialog extends StatefulWidget {
  const _JoinDialog({
    super.key,
  });

  @override
  State<_JoinDialog> createState() => _JoinDialogState();
}

class _JoinDialogState extends State<_JoinDialog> {

  bool wrongCode = false;
  TextEditingController controller = TextEditingController();

  Future<bool> join() async {
    if (controller.text.length != 5) {
      callWrongCode();
      return false;
    }

    bool success = await CourseGateway.instance.join(controller.text.toUpperCase());
    if (success && mounted) {
      return true;
    }

    debugPrint("Wrong Join Code");
    callWrongCode();
    return false;
  }

  void callWrongCode() {
    setState(() {
      wrongCode = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        wrongCode = false;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupDialog(
      alignment: Alignment.center,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Join Course",
                  style: TextStyle(fontSize: 30),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "ABC12"
                    ),
                    textAlign: TextAlign.center,
                    maxLength: 5,
                    maxLines: 1,
                    onSubmitted: (value) {
                      join().then((value) {
                        if (value && mounted) {
                          context.pop(true);
                        }
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Button(
                    text: "Enter",
                    backgroundColor: wrongCode ? Colors.red.shade700 : Theme.of(context).colorScheme.secondary,
                    maxWidth: double.infinity,
                    onClick: (context) {
                      join().then((value) {
                        if (value && mounted) {
                          context.pop(true);
                        }
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}

class _CourseItem extends StatelessWidget {
  const _CourseItem({
    required this.course,
    this.height,
    required this.role,
    required this.isUserTeacher,
    super.key,
  });

  final Course course;
  final double? height;
  final UserRole role;
  final bool isUserTeacher;

  Future<void> edit(BuildContext context) async {
    if (!isUserTeacher) return;
    context.goNamed('course-edit', pathParameters: {'course_id': course.id.toString()});
  }

  void open(BuildContext context) {
    context.goNamed('course', pathParameters: {'course_id': course.id.toString()});
  }

  void openInNewTab(BuildContext context) {
    String path = context.namedLocation("course", pathParameters: {'course_id': course.id.toString()});
    NewTabOpener.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: Text(
        course.shortName,
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.getActiveTheme().calculateTextColor(course.color ?? Colors.blueAccent, context)
        ),
      ),
      body: Text(
        course.name,
        maxLines: 1,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontSize: 16,
        ),
      ),
      actions: isUserTeacher ? [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Button(
            toolTip: "Edit",
            icon: Icons.edit,
            maxWidth: 40,
            onClick: (context) => edit(context),
          ),
        ),
      ] : [],
      color: course.color ?? Colors.blueAccent,
      onClick: (context) => open(context),
      onMiddleClick: (context) => openInNewTab(context),
      onHold: (context) => edit(context),
    );
  }
}

class _CourseCreateDialog extends StatefulWidget {
  const _CourseCreateDialog();

  @override
  State<_CourseCreateDialog> createState() => _CourseCreateDialogState();
}

class _CourseCreateDialogState extends State<_CourseCreateDialog> {

  final nameController = TextEditingController();
  final shortNameController = TextEditingController();
  final descriptionController = TextEditingController();
  Color? color;

  @override
  void dispose() {
    nameController.dispose();
    shortNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> create() async {
    Course course = Course(
      id: -1,
      name: nameController.text.trim(),
      shortName: shortNameController.text.trim(),
      description: descriptionController.text.trim(),
      color: color
    );

    await CourseGateway.instance.create(course);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopupDialog(
        alignment: Alignment.center,
        child: Material(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Create Course",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26),
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: TextField(
                        controller: nameController,
                        autocorrect: true,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        maxLength: 30,
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) => create(),
                      ),
                    ),
                    const SizedBox(width: 15,),
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: shortNameController,
                        autocorrect: true,
                        decoration: const InputDecoration(
                          labelText: 'Short Name',
                        ),
                        maxLength: 5,
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) => create(),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: descriptionController,
                  autocorrect: true,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),

                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) => create(),
                ),
                SlidePicker(
                  pickerColor: Theme.of(context).extension<AppCustomColors>()!.accent,
                  onColorChanged: (value) {
                    color = value;
                  },
                  enableAlpha: false,
                  showIndicator: false,
                  colorModel: ColorModel.rgb,
                ),
                Button(
                  text: "Create Course",
                  maxWidth: double.infinity,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  onClick: (context) => create(),
                )
              ],
            ),
          ),
        )
    );
  }
}