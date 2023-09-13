
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/courseItems/Test.dart';
import 'package:oes/src/restApi/CourseGateway.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
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
      body: WillPopScope(
        onWillPop: () => onWillPop(context),
        child: ListenableBuilder(
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
      ),
    );
  }

  Future<bool> onWillPop(BuildContext context) async {
    bool wantFinishTest = false;
    await showDialog(
      context: context,
      builder: (context) => PopupDialog(
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondary,
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 25,
                  ),
                  child: Text('Finish Test', style: TextStyle(fontSize: 40)),
                ),
                SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Button(
                        text: 'No',
                        onClick: (context) {
                          wantFinishTest = false;
                          context.pop();
                        },
                        maxWidth: 140,
                      ),
                      Button(
                        text: 'Yes',
                        onClick: (context) {
                          wantFinishTest = true;
                          context.pop();
                        },
                        maxWidth: 140,
                        backgroundColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Future.value(wantFinishTest);
  }
}
