import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AppTheme.dart';

class DarkTheme extends AppTheme {

  static final AppTheme instance = DarkTheme();

  // final Color _primary = const Color.fromRGBO(26, 27, 30, 1.0);
  // final Color _secondary = const Color.fromRGBO(17, 18, 21, 1.0);
  // final Color _accent = const Color.fromRGBO(185, 208, 225, 1);
  // final Color _background = const Color.fromRGBO(28, 29, 32, 1.0);
  // final Color _textColorLight = const Color.fromRGBO(250, 250, 250, 1);
  // final Color _textColorDark = const Color.fromRGBO(5, 5, 5, 1);

  final Color _primary = const Color.fromRGBO(37, 40, 53, 1.0);
  final Color _secondary = const Color.fromRGBO(27, 30, 43, 1.0);
  final Color _accent = const Color.fromRGBO(185, 208, 225, 1);
  final Color _background = const Color.fromRGBO(3, 6, 20, 1.0);
  final Color _textColorLight = const Color.fromRGBO(250, 250, 250, 1);
  final Color _textColorDark = const Color.fromRGBO(5, 5, 5, 1);

  @override
  ThemeData getTheme(context) {
    return ThemeData(
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        background: _background,
        surface: _background,
      ),
      extensions: [
        AppCustomColors(
            accent: _accent,
            textColorLight: _textColorLight,
            textColorDark: _textColorDark
        ),
      ],
      useMaterial3: true,
      textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme.apply(
        bodyColor: _textColorLight,
        decorationColor: _textColorLight,
        displayColor: _textColorLight,
      )),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: const Color(0xaaaccef7),
        cursorColor: _accent,
      ),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        labelStyle: MaterialStateTextStyle.resolveWith(
          (states) {
            Color color = states.contains(MaterialState.focused) ? _primary : _textColorLight;
            if (states.contains(MaterialState.hovered)) {
              color = _accent;
            }
            return TextStyle(color: color, letterSpacing: 1.3);
          },
        ),
        floatingLabelStyle: MaterialStateTextStyle.resolveWith(
          (states) {
            return TextStyle(color: _accent, letterSpacing: 1.3);
          }),
        fillColor: _textColorLight,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: _textColorLight,
          )
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: _accent,
          )
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? _accent : Colors.grey;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? _accent : Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          Color lightAccent = _accent.withRed(_accent.red - 30)
                                     .withBlue(_accent.blue - 30)
                                     .withGreen(_accent.green - 30);
          return states.contains(WidgetState.selected) ? lightAccent : Colors.transparent;
        },)
      )
    );
  }
}