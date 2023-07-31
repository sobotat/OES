
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class UserInfoButton extends StatefulWidget {
  const UserInfoButton({
    super.key});

  @override
  State<UserInfoButton> createState() => _UserInfoButtonState();
}

class _UserInfoButtonState extends State<UserInfoButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, child) {
          var user = AppSecurity.instance.user;

          return Button(
            text: user != null ? '${user.firstName} ${user.lastName}' : 'Not Logged',
            toolTip: user != null ? 'Sign-Out' : 'Sign-In',
            onClick: (context) {
              setState(() {
                if (AppSecurity.instance.isLoggedIn()){
                  context.goNamed('sign-out');
                }else {
                  context.goNamed('sign-in', queryParameters: {'path':'/'});
                }
              });
            },
            minWidth: 200,
            maxWidth: double.infinity,
            backgroundColor: AppSecurity.instance.isInit ? AppTheme.getActiveTheme().secondary : Colors.grey, // AppSecurity.instance.isLoggedIn() ? Colors.green[400] : Colors.red[400]
            fontFamily: AppSecurity.instance.isInit ? Theme.of(context).textTheme.bodyMedium!.fontFamily : GoogleFonts.flowCircular().fontFamily,
          );
        },
      ),
    );
  }
}