
import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/src/objects/questions/Review.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class PickManyQuestionBuilder extends QuestionBuilder<PickManyQuestion> {

  const PickManyQuestionBuilder({
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
          headingText: question.name + " (pick many)",
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

}

class _QuestionBody extends StatefulWidget {
  const _QuestionBody({
    required this.question,
    required this.review,
    super.key,
  });

  final PickManyQuestion question;
  final Review? review;

  @override
  State<_QuestionBody> createState() => _QuestionBodyState();
}

class _QuestionBodyState extends State<_QuestionBody> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.question.options.length,
          itemBuilder: (context, index) {
            return _Option(
              question: widget.question,
              index: index,
              isSelected: widget.question.answers.contains(index),
              points: widget.review == null ? null : widget.question.options[index].points,
              onSelected: widget.review == null ? (index, isSelected) {
                if (isSelected && !widget.question.answers.contains(index)) {
                  widget.question.answers.add(index);
                } else if (!isSelected) {
                  widget.question.answers.remove(index);
                }
                setState(() {});
              } : null,
            );
          },
        ),
        widget.review != null ? ReviewBar(
          review: widget.review!,
          question: widget.question,
        ) : Container()
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.question,
    required this.index,
    required this.isSelected,
    required this.points,
    required this.onSelected,
    super.key
  });

  final PickManyQuestion question;
  final int index;
  final bool isSelected;
  final int? points;
  final Function(int index, bool isSelected)? onSelected;

  @override
  Widget build(BuildContext context) {
    Color color = isSelected ? Colors.green.shade700 : Theme.of(context).colorScheme.background;

    return IconItem(
      icon: Text(
        " ${index + 1}.",
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontSize: 12,
            color: AppTheme.getActiveTheme().calculateTextColor(color, context)
        ),
      ),
      body: SelectableText(
        question.options[index].text,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontSize: 16,
        ),
      ),
      color: color,
      onClick: onSelected != null ? (context) {
        onSelected!(index, !isSelected);
      } : null,
      actions: points != null ? [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text("${points}b"),
        )
      ] : [],
    );
  }
}
