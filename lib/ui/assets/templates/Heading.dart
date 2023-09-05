
import 'package:flutter/material.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/ui/assets/templates/Gradient.dart';

class Heading extends StatelessWidget {
  const Heading({
    required this.headingText,
    super.key,
  });

  final String headingText;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Padding(
      padding: EdgeInsets.only(
        left: width > overflow ? 50 : 5,
        right: width > overflow ? 50 : 5,
        top: 40,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SelectableText(
              headingText,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: 25,
              ),
            ),
          ),
          SizedBox(
            height: 2,
            child: GradientContainer(
              colors: [
                Theme.of(context).extension<AppCustomColors>()!.accent,
                Theme.of(context).colorScheme.primary,
              ],
            ),
          ),
        ],
      ),
    );
  }
}