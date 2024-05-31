
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/objects/questions/Question.dart';
import 'package:oes/src/objects/questions/QuestionOption.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:collection/collection.dart';

class PickQuestionEditor extends StatefulWidget {
  const PickQuestionEditor({
    required this.question,
    required this.onUpdated,
    required this.allowSwitchForPoints,
    super.key
  });

  final Question question;
  final Function() onUpdated;
  final bool allowSwitchForPoints;

  @override
  State<PickQuestionEditor> createState() => _PickQuestionEditorState();
}

class _PickQuestionEditorState extends State<PickQuestionEditor> {

  void recalculatePoints() {
    switch(widget.question.type) {
      case "pick-one":
        widget.question.points = widget.question.options
            .map((e) => e.points).max;
        break;
      default:
        widget.question.points = widget.question.options
            .where((element) => element.points >= 0)
            .map((e) => e.points).sum;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.question.options.length,
          itemBuilder: (context, index) {
            return _PickOptions(
              index: index,
              allowSwitchForPoints: widget.allowSwitchForPoints,
              option: widget.question.options[index],
              onUpdated: (index) {
                recalculatePoints();
                widget.onUpdated();
              },
              onDeleted: (index) {
                widget.question.options.removeAt(index);
                recalculatePoints();
                widget.onUpdated();
                setState(() {});
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Button(
            text: "Add Option",
            icon: Icons.add,
            maxWidth: double.infinity,
            backgroundColor: Theme.of(context).extension<AppCustomColors>()!.accent,
            onClick: (context) {
              widget.question.options.add(QuestionOption(id: -1, text: "New Option", points: 0));
              widget.onUpdated();
              setState(() {});
            },
          ),
        )
      ],
    );;
  }
}

class _PickOptions extends StatefulWidget {
  const _PickOptions({
    required this.index,
    required this.option,
    required this.onUpdated,
    required this.onDeleted,
    required this.allowSwitchForPoints,
    super.key,
  });

  final int index;
  final QuestionOption option;
  final Function(int index) onUpdated;
  final Function(int index) onDeleted;
  final bool allowSwitchForPoints;

  @override
  State<_PickOptions> createState() => _PickOptionsState();
}

class _PickOptionsState extends State<_PickOptions> {

  TextEditingController textController = TextEditingController();
  TextEditingController pointsController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    textController.text = widget.option.text;
    pointsController.text = widget.option.points.toString();

    Color color = Theme.of(context).extension<AppCustomColors>()!.accent;
    return IconItem(
      icon: Text(
        " ${widget.index + 1}.",
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
            fontSize: 12,
            color: AppTheme.getActiveTheme().calculateTextColor(color, context)
        ),
      ),
      body: Row(
        children: [
          Flexible(
            child: TextField(
              controller: textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Option Text",
              ),
              onChanged: (value) {
                widget.option.text = value;
                widget.onUpdated(widget.index);
              },
            ),
          ),
          const SizedBox(width: 5,),
          _Points(
            pointsController: pointsController,
            option: widget,
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Button(
              icon: Icons.delete,
              toolTip: "Delete",
              maxWidth: 40,
              backgroundColor: Colors.red.shade700,
              onClick: (context) {
                widget.onDeleted(widget.index);
              },
            ),
          )
        ],
      ),
      height: null,
      color: color,
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }
}

class _Points extends StatefulWidget {
  const _Points({
    super.key,
    required this.pointsController,
    required this.option,
  });

  final TextEditingController pointsController;
  final _PickOptions option;

  @override
  State<_Points> createState() => _PointsState();
}

class _PointsState extends State<_Points> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      child: Builder(
        builder: (context) {
          if (widget.option.allowSwitchForPoints) {
            return Switch(
              value: widget.pointsController.text == "1",
              onChanged: (value) {
                widget.pointsController.text = value ? "1" : "0";
                widget.option.option.points = value ? 1 : 0;
                widget.option.onUpdated(widget.option.index);
                setState(() {});
              },
            );
          }

          return TextField(
            controller: widget.pointsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Points +/-",
            ),
            maxLines: 1,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"^(-?[0-9]*)?$"))
            ],
            onChanged: (value) {
              if (value.isEmpty || value == "-") {
                widget.option.option.points = 0;
                return;
              }
              widget.option.option.points = int.parse(value);
              widget.option.onUpdated(widget.option.index);
            },
          );
        }
      ),
    );
  }
}
