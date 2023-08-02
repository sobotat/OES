import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AppTheme.dart';

class DarkTheme extends AppTheme {

  static final AppTheme instance = DarkTheme();

  final Color _primary = const Color.fromRGBO(21, 34, 47, 1);
  final Color _secondary = const Color.fromRGBO(18, 21, 25, 1.0);
  final Color _accent = const Color.fromRGBO(185, 208, 223, 1);
  final Color _background = const Color.fromRGBO(17, 17, 17, 1);
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
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        labelStyle: MaterialStateTextStyle.resolveWith(
              (Set<MaterialState> states) {
            final Color color = states.contains(MaterialState.focused) ? _secondary : _textColorLight;
            return TextStyle(color: color, letterSpacing: 1.3);
          },
        ),
        fillColor: _textColorLight,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: _textColorLight,
          )
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: _secondary,
          )
        ),
      ),
    );
  }
}