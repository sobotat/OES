import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AppTheme.dart';

class LightTheme extends AppTheme {

  static final AppTheme instance = LightTheme();

  final Color _primary = const Color.fromRGBO(241, 244, 249, 1);
  final Color _secondary = const Color.fromRGBO(221, 231, 240, 1);
  final Color _accent = const Color.fromRGBO(74, 118, 155, 1);
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
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        labelStyle: MaterialStateTextStyle.resolveWith(
          (Set<MaterialState> states) {
            final Color color = states.contains(MaterialState.focused) ? _secondary : _textColorDark;
            return TextStyle(color: color, letterSpacing: 1.3);
          },
        ),
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
    );
  }
}