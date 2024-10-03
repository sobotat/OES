
import 'package:flutter/material.dart';
import 'package:oes/ui/assets/buttons/RefreshButton.dart';
import 'package:oes/ui/assets/buttons/SettingButton.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';

class AppAppBar extends StatefulWidget implements PreferredSizeWidget {
  const AppAppBar({
    this.title,
    this.leading,
    this.actions = const [],
    this.onRefresh,
    this.hideSettings = false,
    super.key
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final Function()? onRefresh;
  final bool hideSettings;

  @override
  final Size preferredSize = const Size.fromHeight(55); // default is 56.0 kToolbarHeight

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
      elevation: 0.5,
      scrolledUnderElevation: 0.5,
      title: widget.title,
      leading: widget.leading,
      actions: [
        Container(
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
                    widget.onRefresh != null ? RefreshButton(onRefresh: widget.onRefresh!) : Container(),
                    const UserInfoButton(width: 150),
                    const SignOutButton(),
                    const ThemeModeButton(),
                    !widget.hideSettings ? const SettingButton() : Container(),
                  ],
                ),
              ),
            ],
          ) : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.onRefresh != null ? RefreshButton(onRefresh: widget.onRefresh!) : Container(),
              SmallMenu(
                actions: widget.actions,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
