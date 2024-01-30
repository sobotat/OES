
import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/objects/questions/PickManyQuestion.dart';
import 'package:oes/ui/assets/templates/AppMarkdown.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/widgets/questions/QuestionBuilder.dart';

class PickManyQuestionBuilder extends QuestionBuilder<PickManyQuestion> {

  const PickManyQuestionBuilder({
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

  final PickManyQuestion question;

  @override
  State<_QuestionBody> createState() => _QuestionBodyState();
}

class _QuestionBodyState extends State<_QuestionBody> {

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
          onSelected: (index, isSelected) {
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
    required this.onSelected,
    super.key
  });

  final PickManyQuestion question;
  final int index;
  final bool isSelected;
  final Function(int index, bool isSelected) onSelected;

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
      onClick: (context) {
        onSelected(index, !isSelected);
      },
    );
  }
}
