import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/src/services/NewTabOpener.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class BackToWeb extends StatelessWidget {
  const BackToWeb({
    this.onlyIcon = true,
    super.key,
  });

  final bool onlyIcon;

  @override
  Widget build(BuildContext context) {
    if (!onlyIcon) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        child: Button(
          text: 'To Web',
          onClick: (context) {
            context.goNamed('/');
          },
          onMiddleClick: (context) {
            NewTabOpener.open(context.namedLocation("/"));
          },
        ),
      );
    }

    return SizedBox(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        child: Button(
          icon: AppIcons.icon_web,
          iconSize: 18,
          onClick: (context) {
            context.goNamed('/');
          },
        ),
      ),
    );
  }
}