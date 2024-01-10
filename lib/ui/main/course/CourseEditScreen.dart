import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
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

class CourseEditScreen extends StatefulWidget {
  const CourseEditScreen({
    required this.courseId,
    super.key,
  });

  final int courseId;

  @override
  State<CourseEditScreen> createState() => _CourseEditScreenState();
}

class _CourseEditScreenState extends State<CourseEditScreen> {

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
            mainAxisSize: MainAxisSize.min,
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
              Flexible(
                child: BackgroundBody(
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
  List<User> teachers = [];
  List<User> students = [];
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
      if (mounted) {
        teachers = value;
        setState(() {});
      }
    });
    widget.course.students.then((value) {
      editCourse!.setStudents(value);
      if (mounted) {
        students = value;
        setState(() {});
      }
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

    course.setTeachers(teachers);

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
    if (editCourse == null) return const Center(child: WidgetLoading(),);
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: _CourseEditTexts(
              nameController: nameController,
              shortNameController: shortNameController,
              descriptionController: descriptionController,
              color: editCourse!.color,
              onSubmitted: () => save(),
            ),
          ),
          const Heading(
            headingText: "Color",
            padding: EdgeInsets.all(5),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
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
            headingText: "Join Code",
            padding: EdgeInsets.all(5),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: _JoinCode(
              course: editCourse!,
            ),
          ),
          const Heading(
            headingText: "Teachers",
            padding: EdgeInsets.all(5),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: _UserSelector(
              course: editCourse!,
              hint: "Teacher Name",
              selectedUsers: teachers,
              hiddenUsers: students,
              filters: const [UserRole.teacher, UserRole.admin],
              onSelected: (user, isSelected) {
                if (isSelected && !students.contains(user)) {
                  teachers.add(user);
                } else if (teachers.length > 1) {
                  teachers.remove(user);
                }
                setState(() {});
              },
            ),
          ),
          const Heading(
            headingText: "Students",
            padding: EdgeInsets.all(5),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: _UserSelector(
              course: editCourse!,
              hint: "Student Name",
              selectedUsers: students,
              hiddenUsers: teachers,
              filters: const [UserRole.student, UserRole.teacher, UserRole.admin],
              onSelected: (user, isSelected) {
                if (isSelected && !teachers.contains(user)) {
                  students.add(user);
                } else {
                  students.remove(user);
                }
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinCode extends StatefulWidget {
  const _JoinCode({
    required this.course,
    super.key,
  });

  final Course course;

  @override
  State<_JoinCode> createState() => _JoinCodeState();
}

class _JoinCodeState extends State<_JoinCode> {

  TextEditingController controller = TextEditingController();
  bool hidden = true;

  @override
  void initState() {
    super.initState();
    CourseGateway.instance.getCode(widget.course).then((value) {
      if (mounted) {
        setState(() {
          controller.text = value ?? "";
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onHideClicked() {
    if (!mounted) return;
    setState(() {
      hidden = !hidden;
    });
  }

  void onCodeChanged(String code) {
    if (!mounted) return;
    setState(() {
      controller.text = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 500;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Code",
                  enabled: false,
                ),
                obscureText: hidden,
              ),
            ),
            width > overflow ? Padding(
              padding: const EdgeInsets.only(top: 10, left: 5),
              child: _JoinCodeButtons(
                hidden: hidden,
                controller: controller,
                course: widget.course,
                onHideClicked: onHideClicked,
                onCodeChanged: onCodeChanged,
              ),
            ) : Container(),
          ],
        ),
        width <= overflow ? Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _JoinCodeButtons(
            hidden: hidden,
            controller: controller,
            course: widget.course,
            expandGenerateButton: true,
            onHideClicked: onHideClicked,
            onCodeChanged: onCodeChanged
          ),
        ) : Container(),
      ],
    );
  }
}

class _JoinCodeButtons extends StatelessWidget {
  const _JoinCodeButtons({
    super.key,
    required this.hidden,
    required this.controller,
    required this.course,
    required this.onHideClicked,
    required this.onCodeChanged,
    this.expandGenerateButton = false,
  });

  final bool hidden;
  final bool expandGenerateButton;
  final TextEditingController controller;
  final Course course;
  final Function() onHideClicked;
  final Function(String code) onCodeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Button(
          icon: hidden ? Icons.remove_red_eye_outlined : Icons.remove_red_eye_rounded,
          toolTip: hidden ? "Show" : "Hide",
          maxWidth: 40,
          onClick: (context) {
            onHideClicked();
          },
        ),
        const SizedBox(width: 5,),
        Button(
          icon: Icons.copy,
          toolTip: "Copy",
          maxWidth: 40,
          onClick: (context) {
            Clipboard.setData(ClipboardData(text: controller.text));
          },
        ),
        const SizedBox(width: 5,),
        Flexible(
          child: Button(
            text: "Generate Code",
            backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
            icon: Icons.new_label,
            maxWidth: expandGenerateButton ? double.infinity : null,
            onClick: (context) async {
              String? code = await CourseGateway.instance.generateCode(course);
              if (code != null) onCodeChanged(code);
            },
          ),
        )
      ],
    );
  }
}

class _UserSelector extends StatefulWidget {
  const _UserSelector({
    required this.course,
    required this.selectedUsers,
    required this.hiddenUsers,
    required this.onSelected,
    required this.hint,
    required this.filters,
  });

  final Course course;
  final String hint;
  final List<UserRole> filters;
  final List<User> selectedUsers;
  final List<User> hiddenUsers;
  final Function(User user, bool isSelected) onSelected;

  @override
  State<_UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<_UserSelector> {

  PagedData<User>? users;
  List<User> filteredUsers = [];
  String filterStr = "";
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      users = await UserGateway.instance.getAllUsers(1, roles: widget.filters, count: 15);
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
    List<User> showUsers = filteredUsers.where((element) => !widget.hiddenUsers.contains(element) && !widget.selectedUsers.contains(element)).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isInit ? ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.selectedUsers.length,
          itemBuilder: (context, index) {
            User user = widget.selectedUsers[index];
            return _UserSelectorButton(
              user: user,
              isInCourse: true,
              onSelectedChanged: (user, isSelected) {
                widget.onSelected(user, isSelected);
              },
            );
          },
        ) : Container(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: TextField(
                autocorrect: true,
                decoration: InputDecoration(
                  labelText: widget.hint,
                  iconColor: showUsers.isEmpty ? Colors.red.shade700 : null,
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
        isInit ? ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: showUsers.length,
          itemBuilder: (context, index) {
            User user = showUsers[index];
            return _UserSelectorButton(
              user: user,
              isInCourse: widget.selectedUsers.contains(user),
              onSelectedChanged: (user, isSelected) {
                widget.onSelected(user, isSelected);
              },
            );
          },
        ) : const Center(child: WidgetLoading()),
      ],
    );
  }
}

class _UserSelectorButton extends StatelessWidget {
  const _UserSelectorButton({
    required this.user,
    required this.isInCourse,
    required this.onSelectedChanged,
  });

  final User user;
  final bool isInCourse;
  final Function(User user, bool isSelected) onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Button(
        text: '${user.firstName} ${user.lastName}',
        backgroundColor: isInCourse ? Colors.green.shade700 : null,
        onClick: (context) {
          onSelectedChanged(user, !isInCourse);
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
