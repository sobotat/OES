import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
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
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 2,
        flexibleSpace: Container(
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
        ),
        title: const _NameBanner(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text('This will be main web page', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.getActiveTheme().primary))),
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
            Text(MediaQuery.of(context).size.width >= 950 ? 'Online E-Learning System' : 'OES', style: TextStyle(fontSize: 22),),
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
                child: _UserWidget(maxWidth: 300, maxHeight: 40,),
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
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const ThemeModeButton(),
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
          SizedBox(
            width: 150,
            child: _UserWidget(),
          ),
          ThemeModeButton(),
        ],
      ),
    );
  }
}

class _UserWidget extends StatefulWidget {
  const _UserWidget({this.maxWidth=-1, this.maxHeight=-1, super.key});

  final double maxWidth;
  final double maxHeight;

  @override
  State<_UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<_UserWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          return Button(
            text: AppSecurity.instance.user?.username ?? 'Not Logged',
            onClick: (context) {
              setState(() {
                if (AppSecurity.instance.isLoggedIn()){
                  context.goNamed('sign-out');
                }else {
                  context.goNamed('sign-in', queryParameters: {'path':'/'});
                }
              });
            },
            minWidth: 200,
            maxWidth: double.infinity,
            backgroundColor: AppSecurity.instance.isInit ? AppTheme.getActiveTheme().secondary : Colors.grey, // AppSecurity.instance.isLoggedIn() ? Colors.green[400] : Colors.red[400]
            fontFamily: AppSecurity.instance.isInit ? Theme.of(context).textTheme.bodyMedium!.fontFamily : GoogleFonts.flowCircular().fontFamily,
          );
        },
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
        backgroundColor: Theme.of(context).colorScheme.secondary,
        minWidth: 200,
        maxWidth: double.infinity,
        onClick: (context) {
          context.goNamed('main');
        },
      ),
    );
  }
}
