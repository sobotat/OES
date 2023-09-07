
import 'package:flutter/material.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';

class SmallMenu extends StatelessWidget {
  const SmallMenu({
    this.actions = const [],
    super.key
  });

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 5,
          ),
          child: Button(
            maxWidth: 100,
            text: 'Menu',
            backgroundColor: Theme.of(context).colorScheme.primary,
            onClick: (context) {
              showDialog(
                context: context,
                builder: (context) => PopupDialog(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const UserInfoButton(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          shouldPopOnClick: true,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ThemeModeButton(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                              ),
                              SignOutButton(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                              ),
                            ],
                          ),
                        ),
                        actions.isNotEmpty ? const Divider() : Container(),
                        actions.isNotEmpty ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: actions,
                        ) : Container(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}