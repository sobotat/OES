
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class CourseTestInfoScreen extends StatefulWidget {
  const CourseTestInfoScreen({
    required this.courseId,
    required this.testId,
    super.key
  });

  final int courseId;
  final int testId;

  @override
  State<CourseTestInfoScreen> createState() => _CourseTestInfoScreenState();
}

class _CourseTestInfoScreenState extends State<CourseTestInfoScreen> {

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    Future(() async {

      isInit = true;
      setState(() {});
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        onRefresh: () {
          setState(() {});
        },
      ),
      body: Builder(
        builder: (context) {
          if (!isInit) return const Center(child: WidgetLoading(),);
          return ListView(
            children: [
              const Heading(
                headingText: "Test Info"
              ),
              const BackgroundBody(
                maxHeight: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 300, child: Text("Same Info"))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              const Heading(headingText: "Score"),
              BackgroundBody(
                maxHeight: double.infinity,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return _Item(
                      index: index,
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.index,
    super.key,
  });

  final int index;

  void show() {
    print("Show");
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 500;

    bool isChecked = (index + 1) % 3 == 0;
    Color iconBackground = isChecked ? Colors.green.shade700 : Colors.deepOrange.shade700;

    return IconItem(
      icon: Text(" ${index + 1}.", style: TextStyle(color: AppTheme.getActiveTheme().calculateTextColor(iconBackground, context))),
      body: const Text("Karel Novák"),
      color: iconBackground,
      actions: [
        Text("${Random().nextInt(10)}b", style: const TextStyle(fontWeight: FontWeight.bold)),
        width > overflow ? SizedBox(width: 200,child: Text(isChecked ? "Checked" : "Waiting for Check", textAlign: TextAlign.center,)) : Container(),
        width <= overflow ? const SizedBox(width: 20,) : Container(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Button(
            icon: Icons.zoom_in,
            toolTip: "Show",
            maxWidth: 40,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onClick: (context) => show(),
          ),
        )
      ],
      onClick: (context) => show(),
    );
  }
}
