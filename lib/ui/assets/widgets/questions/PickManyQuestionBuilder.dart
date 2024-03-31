
import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/objects/questions/AnswerOption.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
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
  void initState() {
    super.initState();
    Future(() {
      if (widget.review != null) {
        Review review = widget.review!;
        for (int index in widget.question.answers) {
          QuestionOption option = widget.question.options[index];
          review.options.add(AnswerOption(questionId: widget.question.id,id: option.id,text: option.text));
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.question.options.length,
      itemBuilder: (context, index) {
        return _Option(
          question: widget.question,
          index: index,
          isSelected: widget.question.answers.contains(index),
          isSelectedReview: widget.review == null ? false : widget.review!.options.where((element) => element.id == widget.question.options[index].id).isNotEmpty,
          onSelected: (index, isSelected) {
            if (widget.review != null) {
              Review review = widget.review!;
              if (review.options.where((element) => element.id == widget.question.options[index].id).isNotEmpty) {
                review.options.removeWhere((element) => element.id == widget.question.options[index].id);
              } else {
                QuestionOption option = widget.question.options[index];
                review.options.add(AnswerOption(questionId: widget.question.id,id: option.id,text: option.text));
              }
              setState(() {});
              return;
            }

            if (isSelected && !widget.question.answers.contains(index)) {
              widget.question.answers.add(index);
            } else if (!isSelected) {
              widget.question.answers.remove(index);
            }
            setState(() {});
          },
        );
      },
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.question,
    required this.index,
    required this.isSelected,
    required this.isSelectedReview,
    this.onSelected,
    super.key
  });

  final PickManyQuestion question;
  final int index;
  final bool isSelected;
  final bool? isSelectedReview;
  final Function(int index, bool isSelected)? onSelected;

  @override
  Widget build(BuildContext context) {
    Color color = isSelected ? Colors.green.shade700 : Theme.of(context).colorScheme.background;
    Color? colorReview = isSelectedReview == null ? null : isSelectedReview! ? Colors.green.shade700 : Theme.of(context).colorScheme.background;

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
      borderColor: colorReview,
      onClick: onSelected != null ? (context) {
        onSelected!(index, isSelectedReview != null ? !isSelectedReview! : !isSelected);
      } : null,
    );
  }
}
