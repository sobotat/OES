import 'package:flutter/material.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class ThemeModeButton extends StatefulWidget {
  const ThemeModeButton({super.key});

  @override
  State<ThemeModeButton> createState() => _ThemeModeButtonState();
}

class _ThemeModeButtonState extends State<ThemeModeButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        child: ListenableBuilder(
          listenable: AppTheme.activeThemeMode,
          builder: (context, child) {
            return Button(
              icon: AppTheme.isDarkMode() ? AppIcons.icon_darkmode : AppIcons.icon_lightmode,
              iconSize: 18,
              backgroundColor: AppTheme.activeThemeMode.themeMode == ThemeMode.system ? AppTheme.getActiveTheme().accent : AppTheme.getActiveTheme().secondary,
              text: '',
              onClick: (context) {
                setState(() {
                  AppTheme.activeThemeMode.changeThemeMode();
                });
              },
            );
          },
        ),
      ),
    );
  }
}
