import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            FilledButton(
                onPressed: () => context.goNamed('/'),
                child: const Text('Back To Home')
            ),
          ],
        ),
      ),
    );
  }
}
