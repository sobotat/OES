import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'AppTheme.dart';

class LightTheme extends AppTheme {

  static final AppTheme instance = LightTheme();

  @override
  Color get primary { return const Color.fromRGBO(102, 197, 233, 1); }
  @override
  Color get secondary { return const Color.fromRGBO(220, 231, 239, 1); }
  @override
  Color get accent { return const Color.fromRGBO(0, 131, 187, 1); }
  @override
  Color get background { return const Color.fromRGBO(250, 250, 250, 1); }
  @override
  Color get textColor { return const Color.fromRGBO(5, 5, 5, 1); }

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
      useMaterial3: true,
      textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme.apply(
        bodyColor: textColor,
        decorationColor: textColor,
        displayColor: textColor,
      )),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        labelStyle: MaterialStateTextStyle.resolveWith(
          (Set<MaterialState> states) {
            final Color color = states.contains(MaterialState.focused) ? secondary : textColor;
            return TextStyle(color: color, letterSpacing: 1.3);
          },
        ),
        fillColor: textColor,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: textColor,
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