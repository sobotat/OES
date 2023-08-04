import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/Objects/Course.dart';
import 'package:oes/ui/assets/Gradient.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/security/Sign-In.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 0,
            ),
            child: const Row(
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
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Column(
              children: [
                const _Heading(
                  headingText: 'Courses:',
                ),
                _Body(
                  child: Builder(
                    builder: (context) {
                      List<Course> courses = [
                        Course(id: 31, name: 'Python', shortName: 'P'),
                        Course(id: 52, name: 'English', shortName: 'E', color: Colors.deepOrange),
                        Course(id: 673, name: 'Java', shortName: 'J', color: Colors.green),
                        Course(id: 1234, name: 'C#', shortName: 'C#'),
                        Course(id: 225, name: 'Math', shortName: 'M', color: Colors.blue[900]),
                      ];

                      return SizedBox(
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
                      );
                    }
                  ),
                )
              ],
            ),
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

class _CourseItem extends StatelessWidget {
  const _CourseItem({
    required this.course,
    this.height,
    super.key,
  });

  final Course course;
  final double? height;

  void open() {
    debugPrint('Open course ${course.name}');
  }

  void exit() {
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
          onLongPress: () => exit(),
          onTap: () => open(),
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
                        onClick: (context) => open(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Button(
                        text: 'Exit',
                        maxWidth: 75,
                        backgroundColor: Colors.red,
                        onClick: (context) => exit(),
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
        minHeight: 200,
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

class _Counter extends StatelessWidget {
  const _Counter({
    super.key,
    required int counter,
  }) : _counter = counter;

  final int _counter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 200,
        width: 350,
        child: GradientContainer(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).extension<AppCustomColors>()!.accent,
          ],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SelectableText(
                'You have pushed the button this many times:',
                style: TextStyle(
                  color: AppTheme.getActiveTheme().calculateTextColor(
                      Theme.of(context).colorScheme.primary, context),
                ),
              ),
              Text(
                '$_counter',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      color: AppTheme.getActiveTheme()
                          .calculateTextColor(
                              Theme.of(context).colorScheme.primary,
                              context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}