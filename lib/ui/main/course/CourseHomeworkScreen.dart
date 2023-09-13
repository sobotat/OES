
import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/CourseItem.dart';
import 'package:oes/src/objects/courseItems/Homework.dart';
import 'package:oes/src/restApi/CourseGateway.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';
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

  Homework? homework;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      homework = await CourseGateway.instance.getCourseItem(widget.courseId, widget.homeworkId) as Homework;
      setState(() { });
    },);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: const AppAppBar(),
      body: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          return FutureBuilder(
            future: CourseGateway.instance.getCourseItem(widget.courseId, widget.homeworkId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: WidgetLoading());
              homework = snapshot.data as Homework;
              return Center(child: Text(homework!.name));
            },
          );
        },
      ),
    );
  }
}
