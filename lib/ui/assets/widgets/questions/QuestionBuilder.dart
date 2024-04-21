
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/Review.dart';

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

class ReviewBar extends StatefulWidget {
  const ReviewBar({
    required this.review,
    required this.question,
    super.key
  });

  final Review review;
  final Question question;

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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Attempt Points: ${widget.question.getPointsFromAnswers()}",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  widget.question is OpenQuestion ? Builder(
                    builder: (context) {
                      double? per = (widget.question as OpenQuestion).similarityPercentage;
                      if(per != null) {
                        per = (per * 10).round() / 10;
                      }
                      return Text(
                        "Similarity: ${per == null ? "Not Calculated Yet" : "$per%"}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      );
                    }
                  ) : Container(),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Builder(
                    builder: (context) {
                      return TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Points",
                        ),
                        maxLines: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"^(-?[0-9]*)?$"))
                        ],
                        onChanged: (value) {
                          if (value.isEmpty || value == "-") {
                            widget.review.points = 0;
                            return;
                          }
                          widget.review.points = int.parse(value);
                        },
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
