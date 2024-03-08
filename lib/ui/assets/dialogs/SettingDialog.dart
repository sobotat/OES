
import 'package:flutter/material.dart';

class SettingDialog extends StatelessWidget {
  const SettingDialog({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: const SizedBox(
        width: 400,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Title()
            ],
          ),
        ),
      ),
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

