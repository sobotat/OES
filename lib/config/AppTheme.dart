import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oes/config/DarkTheme.dart';

import 'LightTheme.dart';

abstract class AppTheme {

  static final ActiveAppTheme activeThemeMode = ActiveAppTheme(ThemeMode.system);

  Color get primary { return Colors.white; }
  Color get secondary { return Colors.white; }
  Color get accent { return Colors.white; }
  Color get background { return Colors.white; }
  Color get textColorLight { return Colors.white; }
  Color get textColorDark { return Colors.black; }

  ThemeData getTheme(context) {
    throw UnimplementedError();
  }

  static bool isDarkMode() {
    if (activeThemeMode.themeMode == ThemeMode.system) {
      var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return activeThemeMode.themeMode == ThemeMode.light ? false : true;
  }

  static AppTheme getActiveTheme(){
    bool isDarkMode = AppTheme.isDarkMode();
    return isDarkMode ? DarkTheme.instance : LightTheme.instance;
  }

  static Brightness calculateBackgroundBrightness(Color background) {
    return background.computeLuminance() >= 0.5 ? Brightness.light : Brightness.dark;
  }

  Color calculateTextColor(Color background){
    return calculateBackgroundBrightness(background) == Brightness.dark ? textColorLight : textColorDark;
  }
}

class ActiveAppTheme extends ChangeNotifier {

  ActiveAppTheme(this._themeMode){
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
      notifyListeners();
    };
  }

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) {
    debugPrint('Active ThemeMode changed [$_themeMode]');
    _themeMode = value;
    notifyListeners();
  }

  void changeThemeMode() {
    if (themeMode == ThemeMode.system) {
      themeMode = ThemeMode.light;
    } else if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }
  }
}