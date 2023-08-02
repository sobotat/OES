import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AppTheme.dart';

class LightTheme extends AppTheme {

  static final AppTheme instance = LightTheme();

  @override
  Color get primary { return const Color.fromRGBO(241, 244, 249, 1); }
  @override
  Color get secondary { return const Color.fromRGBO(221, 231, 240, 1); }
  @override
  Color get accent { return const Color.fromRGBO(74, 118, 155, 1); }
  @override
  Color get background { return const Color.fromRGBO(250, 250, 250, 1); }
  @override
  Color get textColorLight { return const Color.fromRGBO(250, 250, 250, 1); }
  @override
  Color get textColorDark { return const Color.fromRGBO(5, 5, 5, 1); }

  @override
  ThemeData getTheme(context) {
    return ThemeData(
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        background: background,
      ),
      extensions: [
        AppCustomColors(
            accent: accent,
            textColorLight: textColorLight,
            textColorDark: textColorDark
        ),
      ],
      useMaterial3: true,
      textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme.apply(
        bodyColor: textColorDark,
        decorationColor: textColorDark,
        displayColor: textColorDark,
      )),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        labelStyle: MaterialStateTextStyle.resolveWith(
          (Set<MaterialState> states) {
            final Color color = states.contains(MaterialState.focused) ? secondary : textColorDark;
            return TextStyle(color: color, letterSpacing: 1.3);
          },
        ),
        fillColor: textColorDark,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: textColorDark,
          )
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: secondary,
          )
        ),
      ),
    );
  }
}