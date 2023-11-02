import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/PagedData.dart';
import 'package:oes/src/objects/SignedUser.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

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
      debugPrint('Loading Courses');
      courses = await CourseGateway.instance.getUserCourses(user);
      isInit = true;

      if (!mounted) return;
      setState(() {});
    }
  }

  void joinCourse() {
    print("Join");
  }

  void createCourse() async {
    await showDialog(
      context: context,
      builder: (context) => const PopupDialog(child: _CourseCreateDialog()),
    );

    await loadCourses();
    if (mounted) {
      setState(() {});
    }
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
                        return _CourseItem(
                          course: courses[index],
                          height: 50,
                          role: role,
                          onDelete: () async {
                            await loadCourses();
                            setState(() {});
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

class _CourseItem extends StatefulWidget {
  const _CourseItem({
    required this.course,
    this.height,
    required this.role,
    this.onDelete,
    super.key,
  });

  final Course course;
  final double? height;
  final UserRole role;
  final Function()? onDelete;

  @override
  State<_CourseItem> createState() => _CourseItemState();
}

class _CourseItemState extends State<_CourseItem> {

  bool isUserTeacher = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      isUserTeacher = await widget.course.isTeacherInCourse(AppSecurity.instance.user!);
      if (mounted) {
        setState(() {});
      }
    },);
  }

  Future<void> edit(BuildContext context) async {
    if (!isUserTeacher) return;
    await showDialog(
        context: context,
        builder: (context) => _CourseEditDialog(
          course: widget.course,
          onDelete: widget.onDelete,
        ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void open(BuildContext context) {
    context.goNamed('course', pathParameters: {'course_id': widget.course.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      icon: Text(
        widget.course.shortName,
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontSize: 12,
            color: AppTheme.getActiveTheme().calculateTextColor(widget.course.color ?? Colors.blueAccent, context)
        ),
      ),
      body: SelectableText(
        widget.course.name,
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
      color: widget.course.color ?? Colors.blueAccent,
      onClick: (context) => open(context),
      onHold: (context) => edit(context),
    );
  }
}

class _CourseEditDialog extends StatefulWidget {
  const _CourseEditDialog({
    required this.course,
    this.onDelete,
  });

  final Course course;
  final Function()? onDelete;

  @override
  State<_CourseEditDialog> createState() => _CourseEditDialogState();
}

class _CourseEditDialogState extends State<_CourseEditDialog> {

  bool editingTeachers = false;

  final nameController = TextEditingController();
  final shortNameController = TextEditingController();
  final descriptionController = TextEditingController();
  bool colorChanged = false;
  Color color = Colors.blue;
  Course? editCourse;

  @override
  void dispose() {
    nameController.dispose();
    shortNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    editCourse = Course.fromJson(widget.course.toMap());

    nameController.text = editCourse!.name;
    shortNameController.text = editCourse!.shortName;
    descriptionController.text = editCourse!.description;
    widget.course.teachers.then((value) {
      editCourse!.setTeachers(value);
    });

    if (editCourse!.color != null) {
      color = editCourse!.color!;
    }

    setState(() {});
  }

  Future<void> save() async {
    Course course = editCourse!;
    course.name = nameController.text.trim();
    course.shortName = shortNameController.text.trim();
    course.description = descriptionController.text.trim();

    if (colorChanged) course.color = color;

    await CourseGateway.instance.updateCourse(course);
    if (mounted) context.pop();
  }

  Future<void> delete() async {
    await CourseGateway.instance.deleteCourse(widget.course);
    if (widget.onDelete != null) {
      widget.onDelete!();
    }
    if(mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (editCourse == null) return Container();
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
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Edit Course",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  !editingTeachers ? _CourseEditTexts(
                    nameController: nameController,
                    shortNameController: shortNameController,
                    descriptionController: descriptionController,
                    color: editCourse!.color,
                    onColorChanged: (color) {
                      this.color = color;
                      colorChanged = true;
                    },
                    onSubmitted: () => save(),
                  ) : _CourseEditTeachers(
                    course: editCourse!,
                    onTeacherSelectedChanged: (user, isTeacher) {

                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Button(
                      icon: Icons.delete,
                      toolTip: 'Delete',
                      maxWidth: 40,
                      onClick: (context) => delete(),
                      backgroundColor: Colors.red.shade700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Button(
                      icon: !editingTeachers ? Icons.supervised_user_circle : Icons.arrow_back,
                      toolTip: !editingTeachers ? 'Edit Teachers' : 'Back to Edit',
                      maxWidth: 40,
                      onClick: (context) {
                        setState(() {
                          editingTeachers = !editingTeachers;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Button(
                        text: "Save Course",
                        maxWidth: double.infinity,
                        onClick: (context) => save(),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}

class _CourseEditTeachers extends StatefulWidget {
  const _CourseEditTeachers({
    required this.course,
    required this.onTeacherSelectedChanged,
  });

  final Course course;
  final Function(User user, bool isTeacher) onTeacherSelectedChanged;

  @override
  State<_CourseEditTeachers> createState() => _CourseEditTeachersState();
}

class _CourseEditTeachersState extends State<_CourseEditTeachers> {

  PagedData<User>? users;
  List<User> teachers = [];
  List<User> filteredUsers = [];
  String filterStr = "";
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      teachers = await widget.course.teachers;
      users = await UserGateway.instance.getAllUsers(1, roles: [UserRole.teacher, UserRole.admin]);
      filteredUsers = filter(filterStr);
      isInit = true;
      if (mounted) setState(() {});
    },);
  }

  List<User> filter(String searchingFor) {
    List<User> out = [];
    searchingFor = searchingFor.toLowerCase();

    if (users != null) {
      out.addAll(users!.data.where((element) =>
          searchingFor == '' ||
          element.firstName.toLowerCase().contains(searchingFor) ||
          element.lastName.toLowerCase().contains(searchingFor) ||
          '${element.firstName} ${element.lastName}'.toLowerCase().contains(searchingFor) ||
          '${element.lastName} ${element.firstName}'.toLowerCase().contains(searchingFor) ||
          element.username.toLowerCase().contains(searchingFor)
      ));
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: TextField(
                autocorrect: true,
                decoration: InputDecoration(
                  labelText: 'Teacher Name',
                  iconColor: filteredUsers.isEmpty ? Colors.red.shade700 : null,
                  icon: const Icon(Icons.search),
                ),
                maxLines: 1,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  filterStr = value;
                  filteredUsers = filter(filterStr);
                  if (mounted) setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                toolTip: 'Prev',
                icon: Icons.arrow_back,
                maxWidth: 40,
                onClick: users != null ? (users!.havePrev ? (context) {
                  UserGateway.instance.getAllUsers(users!.page - 1, roles: [UserRole.teacher, UserRole.admin]).then((value) {
                    users = value;
                    filteredUsers = filter(filterStr);
                    if (mounted) setState(() {});
                  });
                } : null) : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Button(
                toolTip: 'Next',
                icon: Icons.arrow_forward,
                maxWidth: 40,
                onClick: users != null ? (users!.haveNext ? (context) {
                  UserGateway.instance.getAllUsers(users!.page + 1, roles: [UserRole.teacher, UserRole.admin]).then((value) {
                    users = value;
                    filteredUsers = filter(filterStr);
                    if (mounted) setState(() {});
                  });
                } : null) : null,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 350,
          child: isInit ? ListView.builder(
            shrinkWrap: true,
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              User user = filteredUsers[index];
              return _CourseTeacherSelector(
                user: user,
                course: widget.course,
                isTeacherInCourse: teachers.contains(user),
                onSelectedChanged: (user, isTeacher) {
                  if (teachers.contains(user) && !isTeacher && teachers.length > 1) {
                    teachers.remove(user);
                  } else if (!teachers.contains(user) && isTeacher) {
                    teachers.add(user);
                  }
                  widget.course.setTeachers(teachers);
                  if (mounted) setState(() {});
                },
              );
            },
          ) : const Center(child: WidgetLoading()),
        ),
      ],
    );
  }
}

class _CourseTeacherSelector extends StatelessWidget {
  const _CourseTeacherSelector({
    required this.user,
    required this.course,
    required this.isTeacherInCourse,
    required this.onSelectedChanged,
  });

  final User user;
  final Course course;
  final bool isTeacherInCourse;
  final Function(User user, bool isTeacher) onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Button(
        text: '${user.firstName} ${user.lastName}',
        backgroundColor: isTeacherInCourse ? Colors.green.shade700 : null,
        onClick: (context) {
          onSelectedChanged(user, !isTeacherInCourse);
        },
      ),
    );
  }
}

class _CourseEditTexts extends StatelessWidget {
  const _CourseEditTexts({
    required this.nameController,
    required this.shortNameController,
    required this.descriptionController,
    required this.onColorChanged,
    required this.onSubmitted,
    required this.color,
    super.key
  });

  final TextEditingController nameController, shortNameController, descriptionController;
  final Function(Color color) onColorChanged;
  final Function() onSubmitted;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                onSubmitted: (value) => onSubmitted(),
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
                onSubmitted: (value) => onSubmitted(),
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
          onSubmitted: (value) => onSubmitted(),
        ),
        SlidePicker(
          pickerColor: color ?? Colors.blue,
          onColorChanged: (value) => onColorChanged(value),
          enableAlpha: false,
          showIndicator: false,
          colorModel: ColorModel.rgb,
        ),
      ],
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