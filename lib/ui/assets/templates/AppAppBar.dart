
import 'package:flutter/material.dart';
import 'package:oes/ui/assets/buttons/SettingButton.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';

class AppAppBar extends StatefulWidget implements PreferredSizeWidget {
  const AppAppBar({
    this.title,
    this.actions = const [],
    super.key
  });

  final Widget? title;
  final List<Widget> actions;

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight); // default is 56.0

  @override
  State<AppAppBar> createState() => _AppAppBarState();
}

class _AppAppBarState extends State<AppAppBar> {

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: widget.title,
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 0,
          ),
          child: width > overflow ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: widget.actions,
                    ),
                    const UserInfoButton(width: 150),
                    const SignOutButton(),
                    const ThemeModeButton(),
                    const SettingButton(),
                  ],
                ),
              ),
            ],
          ) : SmallMenu(
            actions: widget.actions,
          ),
        ),
      ],
    );
  }
}
