
import 'package:flutter/material.dart';
import 'package:oes/config/AppSettings.dart';

class SettingDialog extends StatefulWidget {
  const SettingDialog({
    super.key
  });

  @override
  State<SettingDialog> createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Title(),
              _BoolSetting(
                text: "Optimize For Large Screens",
                value: AppSettings.instance.optimizeUIForLargeScreens,
                onChanged: (value) async {
                  AppSettings.instance.optimizeUIForLargeScreens = value ?? true;
                  await AppSettings.instance.save();
                  setState(() {});
                },
              )
            ],
          ),
        ),
      ),
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

class _Title extends StatelessWidget {
  const _Title({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 20,
      ),
      child: Text('Settings',
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

