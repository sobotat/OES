
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/ui/settings/SettingScreen.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/SmallIconButton.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallIconButton(
      icon: Icons.settings,
      toolTip: 'Setting',
      onClick: (context) {
        context.goNamed("setting");
      },
    );
  }
}
