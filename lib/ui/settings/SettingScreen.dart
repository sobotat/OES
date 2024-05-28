
import 'package:flutter/material.dart';
import 'package:oes/config/AppSettings.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/ui/assets/templates/AppAppBar.dart';
import 'package:oes/ui/assets/templates/BackgroundBody.dart';
import 'package:oes/ui/assets/templates/Heading.dart';
import 'package:oes/ui/assets/templates/RefreshWidget.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({
    super.key
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  GlobalKey<RefreshWidgetState> refreshKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RefreshWidget(
      key: refreshKey,
      onRefreshed: () {
        setState(() {});
      },
      child: Scaffold(
        appBar: AppAppBar(
          hideSettings: true,
          onRefresh: () {
            refreshKey.currentState?.refresh();
          },
        ),
        body: ListView(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Heading(headingText: "Setting"),
                BackgroundBody(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Heading(text: "UI"),
                        _BoolSetting(
                          text: "Optimize For Large Screens",
                          value: AppSettings.instance.optimizeUIForLargeScreens,
                          onChanged: (value) async {
                            AppSettings.instance.optimizeUIForLargeScreens = value ?? true;
                            await AppSettings.instance.save();
                            refreshKey.currentState?.refresh();
                          },
                        ),
                        const _Heading(text: "User-Quiz"),
                        _BoolSetting(
                          text: "Enable Repeating Question",
                          value: AppSettings.instance.enableQuestionRepeating,
                          onChanged: (value) async {
                            AppSettings.instance.enableQuestionRepeating = value ?? true;
                            await AppSettings.instance.save();
                            setState(() {});
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: TextStyle(
          color: Theme.of(context).extension<AppCustomColors>()!.accent,
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
        ),
      ],
    );
  }
}

class _BoolSetting extends StatelessWidget {
  const _BoolSetting({
    required this.text,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String text;
  final bool value;
  final Function(bool? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        Switch(
          value: value,
          onChanged: (value) {
            onChanged(value);
          },
        )
      ],
    );
  }
}

