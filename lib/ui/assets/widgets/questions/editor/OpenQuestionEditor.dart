
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/Question.dart';

class OpenQuestionEditor extends StatefulWidget {
  const OpenQuestionEditor({
    required this.question,
    required this.onUpdated,
    super.key
  });

  final Question question;
  final Function() onUpdated;

  @override
  State<OpenQuestionEditor> createState() => _OpenQuestionEditorState();
}

class _OpenQuestionEditorState extends State<OpenQuestionEditor> {

  TextEditingController pointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pointsController.text = widget.question.points.toString();
  }

  @override
  void dispose() {
    pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextField(
        controller: pointsController,
        keyboardType: TextInputType.number,
        maxLines: 1,
        decoration: InputDecoration(
          labelText: "Points",
          labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 14),
        ),
        onChanged: (value) {
          if (value == "-") return;
          try {
            widget.question.points = int.parse(value);
          } on FormatException catch (_) {
            widget.question.points = 0;
            pointsController.text = '0';
          }
          widget.onUpdated();
        },
      ),
    );
  }
}