import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/restApi/CourseGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: const AppAppBar(),
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
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: FloatingActionButton(
              heroTag: '2',
              onPressed: () {
                context.goNamed('user-detail');
              },
              child: const Icon(AppIcons.icon_profile),
            ),
          ),
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
      courses = await CourseGateway.gateway.getUserCourses(user);
      isInit = true;

      if (!context.mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSecurity.instance,
      builder: (context, child) {
        return Column(
          children: [
            const Heading(
              headingText: 'Courses:',
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

class _CourseItem extends StatelessWidget {
  const _CourseItem({
    required this.course,
    this.height,
    super.key,
  });

  final Course course;
  final double? height;

  void open(BuildContext context) {
    debugPrint('Open course ${course.name}');
    context.goNamed('course', pathParameters: {'course_id': course.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return IconItem(
      icon: Text(
        course.shortName,
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontSize: 12,
            color: AppTheme.getActiveTheme().calculateTextColor(course.color ?? Colors.blueAccent, context)
        ),
      ),
      body: SelectableText(
        course.name,
        maxLines: 1,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontSize: 16,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Button(
            text: 'Open',
            maxWidth: 75,
            onClick: (context) => open(context),
          ),
        ),
      ],
      color: course.color ?? Colors.blueAccent,
      onClick: (context) => open(context),
    );
  }
}

