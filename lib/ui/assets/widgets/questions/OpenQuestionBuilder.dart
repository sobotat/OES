
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/src/objects/questions/Review.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class OpenQuestionBuilder extends QuestionBuilder<OpenQuestion> {

  const OpenQuestionBuilder({
    required super.question,
    required super.review,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Heading(
          headingText: question.name,
          actions: [
            Text("Max ${question.points} points")
          ],
        ),
        BackgroundBody(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppMarkdown(
                data: question.description,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: _QuestionBody(
                  question: question,
                  review: review,
                ),
              ),
            ],
          )
        ),
      ],
    );
  }

  @override
  List<AnswerOption> getReview() {
    // TODO: implement getReview
    throw UnimplementedError();
  }
}

class _QuestionBody extends StatefulWidget {
  const _QuestionBody({
    required this.question,
    required this.review,
    super.key,
  });

  final OpenQuestion question;
  final Review? review;

  @override
  State<_QuestionBody> createState() => _QuestionBodyState();
}

class _QuestionBodyState extends State<_QuestionBody> {

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future(() {
      setState(() {
        controller.text = widget.question.answer;
      });
    },);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric( horizontal: 10, vertical: 5),
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextField(
                    enabled: widget.review == null,
                    controller: controller,
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onChanged: (value) {
                      widget.question.answer = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        widget.review != null ? ReviewBar(
          review: widget.review!,
          question: widget.question,
        ) : Container()
      ],
    );
  }
}