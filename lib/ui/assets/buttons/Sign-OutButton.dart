import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

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
          listenable: AppSecurity.instance,
          builder: (context, child) {
            return Button(
              icon: AppIcons.icon_sign_out,
              iconSize: 18,
              backgroundColor: AppSecurity.instance.isLoggedIn() ? Theme.of(context).colorScheme.secondary : Colors.red,
              text: '',
              toolTip: 'Sign-out',
              onClick: (context) {
                context.goNamed('sign-out');
              },
            );
          },
        ),
      ),
    );
  }
}
