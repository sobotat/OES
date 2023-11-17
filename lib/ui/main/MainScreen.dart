import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:oes/ui/assets/templates/PopupDialog.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        actions: kIsWeb ? ([
          _BackToWeb(),
        ]) : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: const [
            _Courses(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: '3',
            onPressed: () {
              context.goNamed('test');
            },
            child: const Icon(AppIcons.icon_darkmode),
          ),
        ],
      ),
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

  List<Course> courses = [];
  Function() listenerFunction = () {};
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    loadCourses();
    listenerFunction = () {
      loadCourses();
    };
    AppSecurity.instance.addListener(listenerFunction);
  }

  @override
  void dispose() {
    super.dispose();
    AppSecurity.instance.removeListener(listenerFunction);
  }

  Future<void> loadCourses() async {
    var user = AppSecurity.instance.user;
    if (user != null) {
      courses = await CourseGateway.instance.getUserCourses(user);
      isInit = true;

      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> joinCourse() async {
    bool success = await showDialog<bool>(
      context: context, 
      builder: (context) {
        return const _JoinDialog();
      }
    ) ?? false;

    print("Connected to Course [$success]");
    if (mounted) {
      await loadCourses();
    }
  }

  void createCourse() async {
    await showDialog(
      context: context,
      builder: (context) => const PopupDialog(child: _CourseCreateDialog()),
    );

    await loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSecurity.instance,
      builder: (context, child) {
        SignedUser? user = AppSecurity.instance.user;
        UserRole role = user == null ? UserRole.student : user.role;
        
        return Column(
          children: [
            Heading(
              headingText: 'Courses:',
              actions: role != UserRole.student ? [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Button(
                    text: "Create",
                    maxWidth: 75,
                    onClick: (context) => createCourse(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Button(
                    text: "Join",
                    maxWidth: 75,
                    onClick: (context) => joinCourse(),
                  ),
                ),
              ] : [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Button(
                    text: "Join",
                    maxWidth: 75,
                    onClick: (context) => joinCourse(),
                  ),
                ),
              ],
            ),
            BackgroundBody(
              child: Builder(
                  builder: (context) {
                    return isInit ? ListView.builder(
                      itemCount: courses.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: courses[index].isTeacherInCourse(AppSecurity.instance.user!),
                          builder: (context, snapshot) {
                            return _CourseItem(
                              course: courses[index],
                              height: 50,
                              role: role,
                              isUserTeacher: snapshot.data ?? false,
                              onUpdated: () async {
                                await loadCourses();
                              },
                            );
                          },
                        );
                      },
                    ) :
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(25),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).extension<AppCustomColors>()!.accent,
                          ),
                        ),
                      ],
                    );
                  }
              ),
            )
          ],
        );
      },
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

    bool success = await CourseGateway.instance.joinCourse(controller.text.toUpperCase());

    if (success && mounted) {
      return true;
    }

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
                    backgroundColor: wrongCode ? Colors.red.shade700 : null,
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
    this.onUpdated,
    super.key,
  });

  final Course course;
  final double? height;
  final UserRole role;
  final bool isUserTeacher;
  final Function()? onUpdated;

  Future<void> edit(BuildContext context) async {
    if (!isUserTeacher) return;
    await context.pushNamed<bool>('course-edit', pathParameters: {'course_id': course.id.toString()});
    if (onUpdated != null) {
      onUpdated!();
    }
  }

  void open(BuildContext context) {
    context.goNamed('course', pathParameters: {'course_id': course.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: Text(
        course.shortName,
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontSize: 12,
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

    await CourseGateway.instance.createCourse(course);
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
              color: Theme
                  .of(context)
                  .colorScheme
                  .background,
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
                  pickerColor: Colors.black,
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
                  onClick: (context) => create(),
                )
              ],
            ),
          ),
        )
    );
  }
}