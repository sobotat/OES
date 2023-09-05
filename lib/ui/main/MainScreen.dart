import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Course.dart';
import 'package:oes/src/restApi/CourseGateway.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';
import 'package:oes/ui/assets/templates/Gradient.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
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
            const _Heading(
              headingText: 'Courses:',
            ),
            _Body(
              child: Builder(
                  builder: (context) {
                    return isInit ? SizedBox(
                      height: (60.0 * courses.length),
                      child: ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          return _CourseItem(
                            course: courses[index],
                            height: 50,
                          );
                        },
                      ),
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
    context.goNamed('course', pathParameters: {'id': course.id.toString()});
  }

  void exit(BuildContext context) {
    debugPrint('Exit course ${course.name}');
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onLongPress: () => exit(context),
          onTap: () => open(context),
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            height: height ?? 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: course.color ?? Colors.blueAccent
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        course.shortName,
                        style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          fontSize: 12,
                          color: AppTheme.getActiveTheme().calculateTextColor(course.color ?? Colors.blueAccent, context)
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: SelectableText(
                        course.name,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
                width > overflow ? Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Button(
                        text: 'Open',
                        maxWidth: 75,
                        onClick: (context) => open(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Button(
                        text: 'Exit',
                        maxWidth: 75,
                        backgroundColor: Colors.red,
                        onClick: (context) => exit(context),
                      ),
                    )
                  ],
                ) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    this.child,
    super.key,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: width > overflow ? 50 : 5,
      ),
      constraints: const BoxConstraints(
        maxHeight: 600,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(4),
          bottom: Radius.circular(10)
        ),
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: child,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.headingText,
    super.key,
  });

  final String headingText;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Padding(
      padding: EdgeInsets.only(
        left: width > overflow ? 50 : 5,
        right: width > overflow ? 50 : 5,
        top: 40,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SelectableText(
              headingText,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: 25,
              ),
            ),
          ),
          SizedBox(
            height: 2,
            child: GradientContainer(
              colors: [
                Theme.of(context).extension<AppCustomColors>()!.accent,
                Theme.of(context).colorScheme.primary,
              ],
            ),
          ),
        ],
      ),
    );
  }
}