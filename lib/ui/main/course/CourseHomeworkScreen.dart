
import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/restApi/interface/CourseGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseHomeworkScreen extends StatefulWidget {
  const CourseHomeworkScreen({
    required this.courseId,
    required this.homeworkId,
    super.key
  });

  final int courseId, homeworkId;

  @override
  State<CourseHomeworkScreen> createState() => _CourseHomeworkScreenState();
}

class _CourseHomeworkScreenState extends State<CourseHomeworkScreen> {

  CourseItem? homework;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          return FutureBuilder(
            future: CourseGateway.instance.getCourseItem(widget.courseId, widget.homeworkId, 'homework'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              homework = snapshot.data as CourseItem;
              return Center(child: Text(homework!.name));
            },
          );
        },
      ),
    );
  }
}
