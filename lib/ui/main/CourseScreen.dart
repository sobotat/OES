
import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/objects/CourseItem.dart';
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
              ),
              BackgroundBody(
                child: FutureBuilder<List<CourseItem>>(
                  future: course!.items,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const _Loading();
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        CourseItem item = snapshot.data![index];
                        if (item is Test) {
                          return _TestWidget(test: item);
                        } else if (item is Homework) {
                          return _HomeworkWidget(homework: item);
                        } else if (item is Quiz) {
                          return _QuizWidget(quiz: item);
                        }
                        return Container();
                      },
                    );
                  },
                ),
              )
            ],
          ) : const Center(
            child: _Loading(),
          );
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
}

class _TestWidget extends StatelessWidget {
  const _TestWidget({
    required this.test,
    super.key
  });

  final Test test;

  @override
  Widget build(BuildContext context) {
    return IconItem(
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
    required this.homework,
    super.key
  });

  final Homework homework;

  @override
  Widget build(BuildContext context) {
    return IconItem(
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
    required this.quiz,
    super.key
  });

  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    return IconItem(
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
    super.key
  });

  final String bodyText;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      bodyText,
      maxLines: 1,
      style: Theme.of(context).textTheme.displayMedium!.copyWith(
        fontSize: 16,
      ),
    );
  }
}
