
import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/ui/assets/templates/Gradient.dart';

class Heading extends StatelessWidget {
  const Heading({
    required this.headingText,
    this.actions,
    this.padding,
    super.key,
  });

  final String headingText;
  final EdgeInsets? padding;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var overflow = 950;

    return Padding(
      padding: padding ?? EdgeInsets.only(
        left: width > overflow ? 50 : 15,
        right: width > overflow ? 50 : 15,
        top: height > overflow / 2 ? 40 : 5,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  headingText,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 25,
                  ),
                ),
              ),
              actions != null ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ) : Container(),
            ],
          ),
          const HeadingLine(),
        ],
      ),
    );
  }
}

class HeadingLine extends StatelessWidget {
  const HeadingLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: GradientContainer(
        colors: [
          Theme.of(context).extension<AppCustomColors>()!.accent,
          Theme.of(context).colorScheme.primary,
        ],
      ),
    );
  }
}