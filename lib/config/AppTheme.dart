import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oes/config/DarkTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LightTheme.dart';

abstract class AppTheme {

  static final ActiveAppTheme activeThemeMode = ActiveAppTheme(ThemeMode.system);

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

  Color calculateTextColor(Color background, BuildContext context){
    var customColors = Theme.of(context).extension<AppCustomColors>()!;
    return calculateBackgroundBrightness(background) == Brightness.dark ? customColors.textColorLight : customColors.textColorDark;
  }
}

class ActiveAppTheme extends ChangeNotifier {

  ActiveAppTheme(this._themeMode){
    SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
      notifyListeners();
    };

    loadSavedTheme().then((value) {
      themeMode = value;
      notifyListeners();
    });
  }

  Future<ThemeMode> loadSavedTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String themeStr = prefs.getString('theme') ?? '';

    if (themeStr == '') {
      return themeMode;
    }

    return themeStr == 'system' ? ThemeMode.system : (themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> saveTheme(ThemeMode themeMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('theme', (themeMode == ThemeMode.system ? 'system' : (themeMode == ThemeMode.dark ? 'dark' : 'light')));
  }

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) {
    debugPrint('Active ThemeMode changed [$_themeMode]');
    _themeMode = value;
    saveTheme(themeMode);
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

class AppCustomColors extends ThemeExtension<AppCustomColors> {

  const AppCustomColors({
    required this.accent,
    required this.textColorLight,
    required this.textColorDark,
  });

  final Color accent;
  final Color textColorLight;
  final Color textColorDark;

  @override
  ThemeExtension<AppCustomColors> copyWith({
    Color? accent,
    Color? textColorLight,
    Color? textColorDark}) {

    return AppCustomColors(
        accent: accent ?? this.accent,
        textColorLight: textColorLight ?? this.textColorLight,
        textColorDark: textColorDark ?? this.textColorDark
    );
  }

  @override
  ThemeExtension<AppCustomColors> lerp(covariant ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) {
      return this;
    }

    return AppCustomColors(
        accent: Color.lerp(accent, other.accent, t) ?? other.accent,
        textColorLight: Color.lerp(textColorLight, other.textColorLight, t) ?? other.textColorLight,
        textColorDark: Color.lerp(textColorDark, other.textColorDark, t) ?? other.textColorDark
    );
  }

}