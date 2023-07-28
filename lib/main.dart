import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppRouter.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/config/DarkTheme.dart';
import 'package:oes/config/LightTheme.dart';
import 'package:oes/src/AppSecurity.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final licenseOutfit = await rootBundle.loadString('google_fonts/Outfit/OFL.txt');
    final licenseFlowCircular = await rootBundle.loadString('google_fonts/FlowCircular/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseOutfit);
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseFlowCircular);
  });

  AppSecurity.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppTheme.activeThemeMode,
      builder: (BuildContext context, Widget? child) {

        return MaterialApp.router(
          title: 'OES',
          debugShowCheckedModeBanner: false,
          theme: LightTheme.instance.getTheme(context),
          darkTheme: DarkTheme.instance.getTheme(context),
          themeMode: AppTheme.activeThemeMode.themeMode,
          routerConfig: AppRouter.instance.router,
        );
      }
    );
  }
}

class WebMain extends StatelessWidget {
  const WebMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: AppSecurity.instance.isLoggedIn() ? Colors.greenAccent : Colors.redAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () => context.goNamed('main'),
              child: const Text('Main Screen'),
            ),
            FilledButton(
              onPressed: () {
                AppSecurity.instance.logout();
                context.goNamed('sign-in');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      )
    );
  }
}

class OtherMain extends StatefulWidget {
  const OtherMain({super.key});

  @override
  State<OtherMain> createState() => _OtherMainState();
}

class _OtherMainState extends State<OtherMain> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppSecurity.instance.isLoggedIn() ? Colors.greenAccent : Colors.redAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: () => context.goNamed('main'),
            child: const Text('Main Screen'),
          ),
          FilledButton(
            onPressed: () {
              AppSecurity.instance.logout();
              context.goNamed('sign-in');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

