import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/PagedData.dart';
import 'package:oes/src/objects/User.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/src/restApi/interface/UserGateway.dart';
import 'package:oes/ui/assets/dialogs/LoadingDialog.dart';
import 'package:oes/ui/assets/dialogs/Toast.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/SizedContainer.dart';
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
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, _) {
          if (!AppSecurity.instance.isInit) return const Center(child: WidgetLoading(),);
          return FutureBuilder(
            future: CourseGateway.instance.get(widget.courseId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              Course course = snapshot.data!;

              return ListView(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                              backgroundColor: Theme.of(context).colorScheme.secondary,
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
                      const SizedBox(height: 10,)
                    ],
                  ),
                ],
              );
            },
          );
        }
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
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );

    Course course = editCourse!;
    course.name = nameController.text.trim();
    course.shortName = shortNameController.text.trim();
    course.description = descriptionController.text.trim();

    course.setTeachers(teachers);

    if (colorChanged) course.color = color;

    await CourseGateway.instance.update(course);

    Toast.makeToast(text: "Course Saved", icon: Icons.save);

    if (mounted) context.pop();
    if (widget.onUpdated != null) {
      widget.onUpdated!();
    }
  }

  Future<void> delete() async {
    await CourseGateway.instance.delete(widget.course);
    if (widget.onDelete != null) {
      widget.onDelete!();
    }
  }

  void onUsersModified() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 500;

    if (editCourse == null) return const Center(child: WidgetLoading(),);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Button(
              text: "Select Color",
              icon: Icons.color_lens,
              maxWidth: double.infinity,
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
          const SizedBox(height: 50,),
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
          const SizedBox(height: 50,),
          width > overflow ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: _TeacherUserSelector(
                  editCourse: editCourse,
                  teachers: teachers,
                  students: students,
                  onModified: onUsersModified,
                ),
              ),
              Flexible(
                flex: 1,
                child: _StudentUserSelector(
                  editCourse: editCourse,
                  students: students,
                  teachers: teachers,
                  onModified: onUsersModified,
                ),
              )
            ],
          ) : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TeacherUserSelector(
                editCourse: editCourse,
                teachers: teachers,
                students: students,
                onModified: onUsersModified,
              ),
              const SizedBox(height: 50,),
              _StudentUserSelector(
                editCourse: editCourse,
                students: students,
                teachers: teachers,
                onModified: onUsersModified,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _StudentUserSelector extends StatelessWidget {
  const _StudentUserSelector({
    super.key,
    required this.editCourse,
    required this.students,
    required this.teachers,
    required this.onModified,
  });

  final Course? editCourse;
  final List<User> students;
  final List<User> teachers;
  final Function() onModified;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Heading(
          headingText: "Students",
          padding: EdgeInsets.all(5),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: _UserSelector(
            course: editCourse!,
            hint: "Name",
            selectedUsers: students,
            hiddenUsers: teachers,
            filters: const [UserRole.student, UserRole.teacher, UserRole.admin],
            onSelected: (user, isSelected) {
              if (isSelected && !teachers.contains(user)) {
                students.add(user);
              } else {
                students.remove(user);
              }
              onModified();
            },
          ),
        ),
      ],
    );
  }
}

class _TeacherUserSelector extends StatelessWidget {
  const _TeacherUserSelector({
    required this.editCourse,
    required this.teachers,
    required this.students,
    required this.onModified,
  });

  final Course? editCourse;
  final List<User> teachers;
  final List<User> students;
  final Function() onModified;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Heading(
          headingText: "Teachers",
          padding: EdgeInsets.all(5),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: _UserSelector(
            course: editCourse!,
            hint: "Name",
            selectedUsers: teachers,
            hiddenUsers: students,
            filters: const [UserRole.teacher, UserRole.admin],
            onSelected: (user, isSelected) {
              if (isSelected && !students.contains(user)) {
                teachers.add(user);
              } else if (teachers.length > 1) {
                teachers.remove(user);
              }
              onModified();
            },
          ),
        ),
      ],
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
    this.count = 15,
  });

  final Course course;
  final String hint;
  final List<UserRole> filters;
  final List<User> selectedUsers;
  final List<User> hiddenUsers;
  final int count;
  final Function(User user, bool isSelected) onSelected;

  @override
  State<_UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<_UserSelector> {

  PagedData<User>? users;
  String filterStr = "";
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      users = await UserGateway.instance.getAllUsers(1, roles: widget.filters, count: widget.count);
      isInit = true;
      if (mounted) setState(() {});
    },);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 500;
    List<User> showUsers = (users?.data ?? []).where((element) => !widget.hiddenUsers.contains(element) && !widget.selectedUsers.contains(element)).toList();

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
                  labelText: '${widget.hint} (Min length is 3)',
                  iconColor: showUsers.isEmpty ? Colors.red.shade700 : null,
                  icon: const Icon(Icons.search),
                ),
                style: TextStyle(color: filterStr.length < 3 ? Colors.red.shade700 : null),
                maxLines: 1,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  filterStr = value;
                  if (filterStr.length < 3) {
                    UserGateway.instance.getAllUsers(1, count: widget.count, roles: widget.filters).then((value) {
                      users = value;
                      if (mounted) setState(() {});
                    });
                    return;
                  }
                  UserGateway.instance.findUsers(1, filterStr, count: widget.count, roles: widget.filters).then((value) {
                    users = value;
                    if (mounted) setState(() {});
                  });
                },
              ),
            ),
            width > overflow && users != null && users!.havePrev ? _PageButton(
              index: users!.page - 1,
              icon: Icons.arrow_back,
              toolTip: 'Prev',
              count: widget.count,
              filterStr: filterStr,
              roles: widget.filters,
              onData: (data) {
                setState(() {
                  users = data;
                });
              },
            ) : Container(),
            width > overflow && users != null && users!.haveNext ? _PageButton(
              index: users!.page + 1,
              icon: Icons.arrow_forward,
              toolTip: 'Next',
              count: widget.count,
              filterStr: filterStr,
              roles: widget.filters,
              onData: (data) {
                setState(() {
                  users = data;
                });
              },
            ) : Container(),
          ],
        ),
        width <= overflow && users != null ? Row(
          children: [
            users!.havePrev ? Flexible(
              flex: 1,
              child: _PageButton(
                index: users!.page - 1,
                icon: Icons.arrow_back,
                toolTip: 'Prev',
                count: widget.count,
                filterStr: filterStr,
                roles: widget.filters,
                width: double.infinity,
                onData: (data) {
                  setState(() {
                    users = data;
                  });
                },
              ),
            ) : Container(),
            users!.haveNext ? Flexible(
              flex: 1,
              child: _PageButton(
                index: users!.page + 1,
                icon: Icons.arrow_forward,
                toolTip: 'Next',
                count: widget.count,
                filterStr: filterStr,
                roles: widget.filters,
                width: double.infinity,
                onData: (data) {
                  setState(() {
                    users = data;
                  });
                },
              ),
            ) : Container()
          ],
        ) : Container(),
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

class _PageButton extends StatelessWidget {
  const _PageButton({
    this.index,
    required this.icon,
    required this.toolTip,
    required this.count,
    required this.filterStr,
    required this.roles,
    required this.onData,
    this.width = 40,
  });

  final int? index;
  final IconData icon;
  final String toolTip;
  final String filterStr;
  final int count;
  final List<UserRole> roles;
  final Function(PagedData<User>? data) onData;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Button(
        toolTip: toolTip,
        icon: icon,
        maxWidth: width,
        onClick: index != null ? (context) {
          if (filterStr.length < 3) {
            UserGateway.instance.getAllUsers(index ?? 1, count: count, roles: roles).then((value) {
              onData(value);
            });
          } else {
            UserGateway.instance.findUsers(index ?? 1, filterStr, count: count, roles: roles).then((value) {
              onData(value);
            });
          }
        } : null,
      ),
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
        maxHeight: 50,
        backgroundColor: isInCourse ? Colors.green.shade700 : null,
        onClick: (context) {
          onSelectedChanged(user, !isInCourse);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${user.firstName} ${user.lastName}'),
            Text(user.username, style: const TextStyle(fontStyle: FontStyle.italic),)
          ],
        ),
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
