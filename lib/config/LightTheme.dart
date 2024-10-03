import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AppTheme.dart';

class LightTheme extends AppTheme {

  static final AppTheme instance = LightTheme();

  final Color _primary = const Color.fromRGBO(240, 240, 240, 1);
  final Color _secondary = const Color.fromRGBO(246, 246, 246, 1.0);
  final Color _accent = const Color.fromRGBO(227, 96, 42, 1);
  final Color _background = const Color.fromRGBO(250, 250, 250, 1);
  final Color _textColorLight = const Color.fromRGBO(250, 250, 250, 1);
  final Color _textColorDark = const Color.fromRGBO(5, 5, 5, 1);

  @override
  ThemeData getTheme(context) {
    return ThemeData(
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: _primary,
        primary: _primary,
        secondary: _secondary,
        background: _background,
        surface: _background
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
        bodyColor: _textColorDark,
        decorationColor: _textColorDark,
        displayColor: _textColorDark,
      )),
      textSelectionTheme: TextSelectionThemeData(
          selectionColor: const Color(0xaaaccef7),
          cursorColor: _accent,
      ),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        labelStyle: MaterialStateTextStyle.resolveWith(
          (states) {
            Color color = states.contains(MaterialState.focused) ? _primary : _textColorDark;
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
        fillColor: _textColorDark,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: _textColorDark,
          )
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: _secondary,
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
          Color lightAccent = _accent.withRed(_accent.red + 20)
                                     .withBlue(_accent.blue + 20)
                                     .withGreen(_accent.green + 20);

          return states.contains(WidgetState.selected) ? lightAccent : Colors.transparent;
        },)
      )
    );
  }
}