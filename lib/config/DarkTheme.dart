import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AppTheme.dart';

class DarkTheme extends AppTheme {

  static final AppTheme instance = DarkTheme();

  @override
    Color get primary { return const Color.fromRGBO(21, 34, 47, 1); }
  @override
  Color get secondary { return const Color.fromRGBO(18, 21, 25, 1.0); }
  @override
  Color get accent { return const Color.fromRGBO(185, 208, 223, 1); }
  @override
  Color get background { return const Color.fromRGBO(17, 17, 17, 1); }
  @override
  Color get textColorLight { return const Color.fromRGBO(250, 250, 250, 1); }
  @override
  Color get textColorDark { return const Color.fromRGBO(5, 5, 5, 1); }

  @override
  ThemeData getTheme(context) {
    return ThemeData(
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
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
        bodyColor: textColorLight,
        decorationColor: textColorLight,
        displayColor: textColorLight,
      )),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        labelStyle: MaterialStateTextStyle.resolveWith(
              (Set<MaterialState> states) {
            final Color color = states.contains(MaterialState.focused) ? secondary : textColorLight;
            return TextStyle(color: color, letterSpacing: 1.3);
          },
        ),
        fillColor: textColorLight,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: textColorLight,
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