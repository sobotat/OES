
import 'package:flutter/material.dart';
import 'package:oes/src/objects/questions/OpenQuestion.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class OpenQuestionBuilder extends QuestionBuilder<OpenQuestion> {

  const OpenQuestionBuilder({
    required super.question,
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
          maxHeight: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppMarkdown(
                data: question.description,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: _QuestionBody(question: question),
              ),
            ],
          )
        ),
      ],
    );
  }
}

class _QuestionBody extends StatefulWidget {
  const _QuestionBody({
    required this.question,
    super.key,
  });

  final OpenQuestion question;

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
        controller.text = widget.question.answer ?? "";
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
    return Padding(
      padding: const EdgeInsets.symmetric( horizontal: 10, vertical: 5),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: TextField(
            controller: controller,
            autocorrect: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onChanged: (value) {
              widget.question.answer = value;
            },
          ),
        ),
      ),
    );
  }
}