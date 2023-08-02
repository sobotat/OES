import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/ui/assets/Gradient.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/security/Sign-In.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      UserInfoButton(
                        width: 150,
                      ),
                      SignOutButton(),
                      ThemeModeButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          height: 200,
          width: 350,
          child: GradientContainer(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).extension<AppCustomColors>()!.accent,
            ],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SelectableText(
                    'You have pushed the button this many times:',
                    style: TextStyle(
                      color: AppTheme.getActiveTheme().calculateTextColor(Theme.of(context).colorScheme.primary, context),
                    ),
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.getActiveTheme().calculateTextColor(Theme.of(context).colorScheme.primary, context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: FloatingActionButton(
              heroTag: '1',
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: FloatingActionButton(
              heroTag: '2',
              onPressed: () {
                context.goNamed('user-detail');
              },
              child: const Icon(AppIcons.icon_profile),
            ),
          ),
          FloatingActionButton(
            heroTag: '3',
            onPressed: () {
              context.goNamed('test');
            },
            child: const Icon(AppIcons.icon_darkmode),
          ),
        ],
      ),
    );
  }
}