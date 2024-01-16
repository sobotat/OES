
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/interface/courseItems/TestGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseTestEditScreen extends StatefulWidget {
  const CourseTestEditScreen({
    required this.courseId,
    required this.testId,
    super.key
  });

  final int courseId;
  final int testId;

  @override
  State<CourseTestEditScreen> createState() => _CourseTestEditScreenState();
}

class _CourseTestEditScreenState extends State<CourseTestEditScreen> {

  Test test = Test(id: -1, name: "", created: DateTime.now(), createdById: AppSecurity.instance.user!.id, scheduled: DateTime.now(), end: DateTime.now(), duration: 0, isVisible: true, maxAttempts: 1);

  @override
  void initState() {
    super.initState();

  }

  void save(){}

  void delete(){}

  bool isNewTest() { return widget.testId == -1; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: FutureBuilder<Test>(
        future: Future(() async {
          if (!isNewTest()) {
            return await TestGateway.instance.get(widget.courseId, widget.testId) ?? test;
          } else {
            return test;
          }
        },),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Load Test Error: ${snapshot.error}");
            context.pop();
          }
          if (!snapshot.hasData) return const Center(child: WidgetLoading(),);
          test = snapshot.data!;

          return ListView(
            children: [
              Heading(
                headingText: isNewTest() ? "Create Test" : "Edit Test",
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Button(
                      icon: Icons.save,
                      toolTip: "Save",
                      maxWidth: 40,
                      onClick: (context) {
                        print("Sending Save");
                        save();
                      },
                    ),
                  ),
                  isNewTest() ? Padding(
                    padding: const EdgeInsets.all(5),
                    child: Button(
                      icon: Icons.delete,
                      toolTip: "Delete",
                      maxWidth: 40,
                      backgroundColor: Colors.red.shade700,
                      onClick: (context) {
                        print("Sending Delete");
                        delete();
                      },
                    ),
                  ) : Container()
                ],
              ),
              BackgroundBody(
                maxHeight: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("To be Added"),
                ),
              ),
              const SizedBox(height: 10,)
            ],
          );
        },
      ),
    );
  }
}
