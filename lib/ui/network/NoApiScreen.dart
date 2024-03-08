import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/ui/assets/buttons/SettingButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class NoApiScreen extends StatefulWidget {
  const NoApiScreen({
    required this.path,
    super.key
  });

  final String path;

  @override
  State<NoApiScreen> createState() => _NoApiScreenState();
}

class _NoApiScreenState extends State<NoApiScreen> {

  goBack(BuildContext context) {
    context.go(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
        Stack(
          children: [
            Center(
              child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text('Api is Down',
                        style: TextStyle(
                          fontSize: 40,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ),
                    Button(
                      text: 'Go Back',
                      maxWidth: 150,
                      onClick: (context) => goBack(context),
                    )
                  ],
                ),
              ),
            const Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeModeButton(),
                  SettingButton()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
