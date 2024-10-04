import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/assets/buttons/BackToWeb.dart';
import 'package:oes/ui/assets/buttons/SettingButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SignOut extends StatefulWidget {
  const SignOut({super.key});

  @override
  State<SignOut> createState() => _SignOutState();
}

class _SignOutState extends State<SignOut> {

  @override
  void initState() {
    super.initState();
    AppSecurity.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
          Stack(
            children: [Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Signed Out',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                  Button(
                    text: 'Continue',
                    onClick: (context) {
                      context.goNamed('sign-in', queryParameters: {
                        "path": "/",
                      });
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  kIsWeb ? const BackToWeb() : Container(),
                  const ThemeModeButton(),
                  const SettingButton()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
