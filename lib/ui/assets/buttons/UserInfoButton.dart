import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class UserInfoButton extends StatelessWidget {
  const UserInfoButton({
    this.width,
    this.padding,
    this.shouldPopOnClick = false,
    super.key,
  });

  final bool shouldPopOnClick;
  final double? width;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        child: ListenableBuilder(
          listenable: AppSecurity.instance,
          builder: (context, child) {
            var user = AppSecurity.instance.user;

            Color background = AppSecurity.instance.isInit ? Theme.of(context).colorScheme.primary : Colors.grey;
            Color textColor = AppTheme.getActiveTheme().calculateTextColor(background, context);

            return Button(
              toolTip: user != null ? 'User Detail' : 'Sign-In',
              shouldPopOnClick: shouldPopOnClick,
              onClick: (context) {
                context.goNamed('user-detail');
              },
              minWidth: 200,
              maxWidth: double.infinity,
              backgroundColor: background,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppApi.instance.useMockApi ? Tooltip(
                    message: 'Mock Api',
                    waitDuration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(Icons.account_tree, size: 20, color: textColor,),
                    ),
                  ) : Container(),
                  Text(
                    user != null ? '${user.firstName} ${user.lastName}' : 'Not Logged',
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                      fontFamily: AppSecurity.instance.isInit ? Theme.of(context).textTheme.bodyMedium!.fontFamily : GoogleFonts.flowCircular().fontFamily,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}