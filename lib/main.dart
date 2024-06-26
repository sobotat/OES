import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/config/AppRouter.dart';
import 'package:oes/config/AppSettings.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/config/DarkTheme.dart';
import 'package:oes/config/LightTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/services/NetworkChecker.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LicenseRegistry.addLicense(() async* {
    final licenseOutfit = await rootBundle.loadString('google_fonts/Outfit/OFL.txt');
    final licenseFlowCircular = await rootBundle.loadString('google_fonts/FlowCircular/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseOutfit);
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseFlowCircular);
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    AppSettings.instance.load().then((value) {
      AppApi.instance.init().then((value) {
        AppSecurity.instance.init();
        NetworkChecker.instance.init();
        AppRouter.instance.setNetworkListener();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppApi.instance,
      builder: (context, _) {
        if (!AppApi.instance.isInit) {
          return Material(
            color: AppTheme.getActiveTheme().getTheme(context).colorScheme.background,
          );
        }
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
    );
  }
}