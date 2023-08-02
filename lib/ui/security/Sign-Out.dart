import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class SignOut extends StatelessWidget {
  const SignOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
              text: 'Back To Home',
              onClick: (context) => context.goNamed('/'),
            ),
          ],
        ),
      ),
    );
  }
}
