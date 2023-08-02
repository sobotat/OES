import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/assets/Gradient.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                width >= overflow ? const _LargeMenu() : const _SmallMenu(),
              ],
            ),
          )
        ],
        title: const _NameBanner(),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: SizedBox(
                height: 500,
                child: GradientContainer(
                  borderRadius: BorderRadius.zero,
                  colors: [
                    Theme.of(context).extension<AppCustomColors>()!.accent,
                    Theme.of(context).colorScheme.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  child: const Text('Online E-Learning System'),
                ),
              ),
            ),
            Container(
              color: Colors.red,
              alignment: Alignment.topCenter,
              child: Text('Hello'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameBanner extends StatelessWidget {
  const _NameBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.add_chart),
            ),
            Text(MediaQuery.of(context).size.width >= 950 ? 'Online E-Learning System' : 'OES', style: const TextStyle(fontSize: 22),),
          ],
        );
      }
    );
  }
}

class _SmallMenu extends StatelessWidget {
  const _SmallMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PopupMenuButton<int>(
            constraints: const BoxConstraints(
              minWidth: 250,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                value: 1,
                child: Row(
                  children: [
                    Expanded(
                        child: UserInfoButton()
                    ),
                    SignOutButton(),
                  ],
                ),
              ),
              const PopupMenuItem(
                enabled: false,
                value: 1,
                child: _GoToMain(),
              ),
            ],
            offset: const Offset(0, 100),
            color: Colors.grey,
            elevation: 2,
            child: SizedBox(
              width: 100,
              child: Button(
                text: 'Menu',
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const Row(
            children: [
              ThemeModeButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _LargeMenu extends StatelessWidget {
  const _LargeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 150,
            child: _GoToMain(),
          ),
          UserInfoButton(
            width: 150,
          ),
          SignOutButton(),
          ThemeModeButton(),
        ],
      ),
    );
  }
}

class _GoToMain extends StatelessWidget {
  const _GoToMain({
    super.key,
  });

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
        minWidth: 200,
        maxWidth: double.infinity,
        onClick: (context) {
          context.goNamed('main');
        },
      ),
    );
  }
}
