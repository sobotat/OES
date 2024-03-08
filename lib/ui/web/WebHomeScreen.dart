import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/Gradient.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class WebHomeScreen extends StatefulWidget {
  const WebHomeScreen({super.key});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: AppAppBar(
        actions: [
          width > overflow ? const _GoToMain(maxWidth: 150,) : const _GoToMain(),
        ],
      ),
      body: ListView(
        children: [
          _Title(width: width, overflow: overflow),
          const _WhyToUse(),
        ],
      ),
    );
  }
}

class _WhyToUse extends StatelessWidget {
  const _WhyToUse({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Learn with fun and ease"),
        Text("Create your own quiz as student"),
        Text("Use it on all Platforms"),
        _ImageBanner(text: "aaaaaaaaaaaaaaa")
      ],
    );
  }
}

class _ImageBanner extends StatelessWidget {
  const _ImageBanner({
    required this.text,
    super.key
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Center(
            child: Text(text, textAlign: TextAlign.right,),
          )
        ),
        Flexible(
          child: Image.network(
            "https://media.istockphoto.com/id/952696392/vector/television-test-card.jpg?s=612x612&w=0&k=20&c=HLKN1cPrugPVtcPI6RK60CVb2wKq39ERVa9LgfLW38s=",
            height: 400,
            width: 400,
          )
        ),
      ],
    );
  }
}


class _Title extends StatelessWidget {
  const _Title({
    super.key,
    required this.width,
    required this.overflow,
  });

  final double width;
  final int overflow;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: GradientContainer(
        borderRadius: BorderRadius.zero,
        colors: [
          Theme.of(context).colorScheme.secondary,
          Theme.of(context).extension<AppCustomColors>()!.accent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 700,
              child: Center(
                child: Text(width > overflow ? 'Online E-Learning System' : 'Online\nE-Learning\nSystem',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontSize: width > overflow ? 50 : 35,
                    letterSpacing: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getActiveTheme().calculateTextColor(Theme.of(context).colorScheme.secondary, context)
                  ),
                  textAlign: TextAlign.center
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoToMain extends StatelessWidget {
  const _GoToMain({
    this.maxWidth = double.infinity,
  });

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Button(
        text: 'Enter',
        backgroundColor: Theme.of(context).colorScheme.primary,
        minWidth: 100,
        maxWidth: maxWidth,
        onClick: (context) {
          context.goNamed('main');
        },
      ),
    );
  }
}