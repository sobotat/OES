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
    return ListenableBuilder(
      listenable: AppSecurity.instance,
      builder: (context, child) {
        return AppSecurity.instance.isLoggedIn() ? SizedBox(
          width: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 10,
            ),
            child: Button(
              icon: AppIcons.icon_sign_out,
              iconSize: 18,
              backgroundColor: Theme.of(context).colorScheme.primary,
              text: '',
              toolTip: 'Sign-out',
              onClick: (context) {
                context.goNamed('sign-out');
              },
            ),
          ),
        ) :
        Container();
      },
    );
  }
}
