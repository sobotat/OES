import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/PagedData.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseEditPage extends StatefulWidget {
  const CourseEditPage({
    required this.courseId,
    super.key,
  });

  final int courseId;

  @override
  State<CourseEditPage> createState() => _CourseEditPageState();
}

class _CourseEditPageState extends State<CourseEditPage> {

  GlobalKey<_CourseEditWidgetState> editWidgetStateKey = GlobalKey<_CourseEditWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: FutureBuilder(
        future: CourseGateway.instance.getCourse(widget.courseId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: WidgetLoading());
          Course course = snapshot.data!;

          return Column(
            children: [
              Heading(
                headingText: "Edit Course",
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Button(
                      icon: Icons.save,
                      toolTip: "Save",
                      maxWidth: 40,
                      onClick: (context) {
                        print("Sending Save");
                        editWidgetStateKey.currentState?.save();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Button(
                      icon: Icons.delete,
                      toolTip: "Delete",
                      maxWidth: 40,
                      backgroundColor: Colors.red.shade700,
                      onClick: (context) {
                        print("Sending Delete");
                        editWidgetStateKey.currentState?.delete();
                      },
                    ),
                  )
                ],
              ),
              BackgroundBody(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _CourseEditWidget(
                    key: editWidgetStateKey,
                    course: course,
                    onDelete: () => context.pop(true),
                    onUpdated: () => context.pop(true),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CourseEditWidget extends StatefulWidget {
  const _CourseEditWidget({
    required this.course,
    this.onUpdated,
    this.onDelete,
    super.key,
  });

  final Course course;
  final Function()? onUpdated;
  final Function()? onDelete;

  @override
  State<_CourseEditWidget> createState() => _CourseEditWidgetState();
}

class _CourseEditWidgetState extends State<_CourseEditWidget> {
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
    if (widget.onUpdated != null) {
      widget.onUpdated!();
    }
  }

  Future<void> delete() async {
    await CourseGateway.instance.deleteCourse(widget.course);
    if (widget.onDelete != null) {
      widget.onDelete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (editCourse == null) return Container();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: ListView(
        shrinkWrap: true,
        children: [
          const Heading(
            headingText: "Info",
            padding: EdgeInsets.all(5),
          ),
          _CourseEditTexts(
            nameController: nameController,
            shortNameController: shortNameController,
            descriptionController: descriptionController,
            color: editCourse!.color,
            onSubmitted: () => save(),
          ),
          const Heading(
            headingText: "Color",
            padding: EdgeInsets.all(5),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Button(
              text: "Select Color",
              icon: Icons.color_lens,
              backgroundColor: color,
              onClick: (context) async {
                await showDialog(
                  context: context,
                  builder: (context) =>
                    _ColorDialog(
                      color: color,
                      onColorChanged: (color) {
                        this.color = color;
                        colorChanged = true;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                  ),
                );
              },
            ),
          ),
          const Heading(
            headingText: "Teachers",
            padding: EdgeInsets.all(5),
          ),
          _CourseEditTeachers(
            course: editCourse!,
            onTeacherSelectedChanged: (user, isTeacher) {

            },
          ),
          const Heading(
            headingText: "Students",
            padding: EdgeInsets.all(5),
          ),
        ],
      ),
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
            physics: const NeverScrollableScrollPhysics(),
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
    required this.onSubmitted,
    required this.color,
    super.key
  });

  final TextEditingController nameController, shortNameController, descriptionController;
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
      ],
    );
  }
}

class _ColorDialog extends StatelessWidget {
  const _ColorDialog({
    required this.onColorChanged,
    this.color,
    super.key
  });

  final Color? color;
  final Function(Color color) onColorChanged;

  @override
  Widget build(BuildContext context) {
    return PopupDialog(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 200,
        width: 300,
        padding: const EdgeInsets.all(10),
        child: SlidePicker(
          pickerColor: color ?? Colors.blue,
          onColorChanged: (value) => onColorChanged(value),
          enableAlpha: false,
          showIndicator: false,
          colorModel: ColorModel.rgb,
        ),
      )
    );
  }
}
