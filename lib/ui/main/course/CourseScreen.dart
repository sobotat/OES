
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/OtherUser.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/objects/courseItems/Quiz.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/CourseGateway.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({
    required this.courseID,
    super.key
  });

  final int courseID;

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {

  bool isInit = false;
  Course? course;
  Function() listenerFunction = () {};

  @override
  void initState() {
    super.initState();
    loadCourse();
    listenerFunction = () {
      loadCourse();
    };
    AppSecurity.instance.addListener(listenerFunction);
  }

  @override
  void dispose() {
    super.dispose();
    AppSecurity.instance.removeListener(listenerFunction);
  }

  Future<void> loadCourse() async {
    var user = AppSecurity.instance.user;
    if (user != null) {
      debugPrint('Loading Course');
      course = await CourseGateway.gateway.getCourse(widget.courseID);
      isInit = true;

      if (context.mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 0,
            ),
            child: width > overflow ? const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      UserInfoButton(
                        width: 150,
                      ),
                      SignOutButton(),
                      ThemeModeButton(),
                    ],
                  ),
                ),
              ],
            ) : const SmallMenu(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          return course != null ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Heading(
                headingText: course!.name,
                actions: width > overflow ? [
                  SizedBox(
                    height: 40,
                    child: _TeachersBuilder(
                      course: course!,
                      axis: Axis.horizontal,
                    ),
                  )
                ] : null,
              ),
              const SizedBox(height: 10,),
              _Description(width: width, overflow: overflow, course: course!),
              (width > overflow && course!.description != '') || width <= overflow ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width > overflow ? 50 : 15,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    const HeadingLine(),
                  ],
                ),
              ) : Container(),
              BackgroundBody(
                child: FutureBuilder<List<CourseItem>>(
                  future: course!.items,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const WidgetLoading();
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        CourseItem item = snapshot.data![index];
                        if (item is Test) {
                          return _TestWidget(
                            course: course!,
                            test: item
                          );
                        } else if (item is Homework) {
                          return _HomeworkWidget(
                            course: course!,
                            homework: item
                          );
                        } else if (item is Quiz) {
                          return _QuizWidget(
                            course: course!,
                            quiz: item,
                          );
                        }
                        return Container();
                      },
                    );
                  },
                ),
              )
            ],
          ) : const Center(
            child: WidgetLoading(),
          );
        },
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    required this.course,
    required this.width,
    required this.overflow,
    super.key,
  });

  final Course course;
  final double width;
  final int overflow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width > overflow ? 50 : 15,
      ),
      child: width > overflow ? Align(
        alignment: Alignment.centerLeft,
        child: Container(
          child: course!.description != '' ? SelectableText(
            course!.description,
          ) : Container(),
        ),
      ) : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          course!.description != '' ? SelectableText(
            course!.description,
          ) : Container(),
          course!.description != '' ? const SizedBox(height: 20,) : Container(),
          SizedBox(
            height: 40,
            child: _TeachersBuilder(
              course: course,
              axis: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeachersBuilder extends StatelessWidget {
  const _TeachersBuilder({
    required this.course,
    required this.axis,
    super.key,
  });

  final Course course;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: course.teachers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.length,
          scrollDirection: axis,
          itemBuilder: (context, index) {
            return TeacherWidget(
                teacher: snapshot.data![index],
            );
          },
        );
      }
    );
  }
}

class _TestWidget extends StatelessWidget {
  const _TestWidget({
    required this.course,
    required this.test,
    super.key
  });

  final Course course;
  final Test test;

  void openTest(BuildContext context) {
    debugPrint('Open test ${test.name}');
    context.goNamed('course-test', pathParameters: {
      'course_id': course.id.toString(),
      'test_id': test.id.toString()}
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) => openTest(context),
      icon: const _IconText(
          text: 'Test',
          backgroundColor: Colors.red
      ),
      body: _ItemBody(
        bodyText: test.name,
      ),
      color: Colors.red,
    );
  }
}

class _HomeworkWidget extends StatelessWidget {
  const _HomeworkWidget({
    required this.course,
    required this.homework,
    super.key
  });

  final Course course;
  final Homework homework;

  void openHomework(BuildContext context) {
    debugPrint('Open homework ${homework.name}');
    context.goNamed('course-homework', pathParameters: {
      'course_id': course.id.toString(),
      'homework_id': homework.id.toString()}
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) => openHomework(context),
      icon: const _IconText(
          text: 'Hw',
          backgroundColor: Colors.blueAccent
      ),
      body: _ItemBody(
        bodyText: homework.name,
      ),
      color: Colors.blueAccent,
    );
  }
}

class _QuizWidget extends StatelessWidget {
  const _QuizWidget({
    required this.course,
    required this.quiz,
    super.key
  });

  final Course course;
  final Quiz quiz;

  void openQuiz(BuildContext context) {
    debugPrint('Open quiz ${quiz.name}');
    context.goNamed('course-quiz', pathParameters: {
      'course_id': course.id.toString(),
      'quiz_id': quiz.id.toString()}
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconItem(
      onClick: (context) => openQuiz(context),
      icon: const _IconText(
        text: 'Qz',
        backgroundColor: Colors.greenAccent
      ),
      body: _ItemBody(
        bodyText: quiz.name,
      ),
      color: Colors.greenAccent,
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({
    required this.text,
    required this.backgroundColor,
    super.key
  });

  final String text;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.displaySmall!.copyWith(
          fontSize: 12,
          color: AppTheme.getActiveTheme().calculateTextColor(backgroundColor, context)
      ),
    );
  }
}

class _ItemBody extends StatelessWidget {
  const _ItemBody({
    required this.bodyText,
    this.padding = const EdgeInsets.all(0),
    super.key
  });

  final String bodyText;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SelectableText(
        bodyText,
        maxLines: 1,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontSize: 16,
        ),
      ),
    );
  }
}

class TeacherWidget extends StatelessWidget {
  const TeacherWidget({
    required this.teacher,
    super.key
  });

  final OtherUser teacher;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${teacher.firstName} ${teacher.lastName}',
      child: IconItem(
        icon: _IconText(
          text: (teacher.firstName[0] + teacher.lastName[0]).toUpperCase(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        color: Theme.of(context).colorScheme.secondary,
        height: 35,
        mainSize: MainAxisSize.min,
        padding: EdgeInsets.symmetric(horizontal: 2),
      ),
    );
  }
}
