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

String getActiveThemeModeName() {
  return '${AppTheme.isDarkMode() ? 'Dark' : 'Light'}  ${ThemeMode.system == AppTheme.activeThemeMode.themeMode ? '(System)' : ''}';
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
      body: Container(
        alignment: Alignment.topCenter,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height: 500,
              child: GradientContainer(
                borderRadius: BorderRadius.zero,
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).extension<AppCustomColors>()!.accent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
            Container(
              padding: const EdgeInsets.all(100),
              color: Theme.of(context).extension<AppCustomColors>()!.accent,
              alignment: Alignment.topCenter,
              child: Text('Some smart text why to use it',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 20,
                  color: AppTheme.getActiveTheme().calculateTextColor(Theme.of(context).extension<AppCustomColors>()!.accent, context),
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