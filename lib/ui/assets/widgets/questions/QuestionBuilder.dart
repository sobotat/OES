
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';

abstract class QuestionBuilder<Question> extends StatelessWidget {

  const QuestionBuilder({
    required this.question,
    required this.review,
    super.key,
  });

  final Question question;
  final Review? review;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}

class Review {
  List<AnswerOption> options = [];
  int? points;
}

class ReviewBar extends StatefulWidget {
  const ReviewBar({
    required this.review,
    super.key
  });

  final Review review;

  @override
  State<ReviewBar> createState() => _ReviewBarState();
}

class _ReviewBarState extends State<ReviewBar> {

  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.review.points == null ? "" : widget.review.points.toString();
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLines: 1,
      onChanged: (value) {
        widget.review.points = int.tryParse(value.trim());
        if (widget.review.points == null) setState(() {});
      },
    );
  }
}
