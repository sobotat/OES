
import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/CourseGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseTestScreen extends StatefulWidget {
  const CourseTestScreen({
    required this.courseId,
    required this.testId,
    super.key
  });

  final int courseId;
  final int testId;

  @override
  State<CourseTestScreen> createState() => _CourseTestScreenState();
}

class _CourseTestScreenState extends State<CourseTestScreen> {

  Test? test;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          return FutureBuilder(
            future: CourseGateway.instance.getCourseItem(widget.courseId, widget.testId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              test = snapshot.data as Test;
              return Center(child: Text(test!.name));
            },
          );
        },
      ),
    );
  }
}
