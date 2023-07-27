import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/src/AppSecurity.dart';

class SignIn extends StatefulWidget {
  const SignIn({this.path = '/', super.key});

  final String path;

  @override
  State<SignIn> createState() => _SignInState(path: path);
}

class _SignInState extends State<SignIn> {

  _SignInState({this.path = '/'});

  final String path;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    bool success = await AppSecurity.instance.login(usernameController.text, passwordController.text);
    if (!success) {
      debugPrint('Invalid Username or Password');
      return;
    }

    openHome();
  }

  void openHome() {
    context.goNamed(path);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 100,
          horizontal: 25,
        ),
        child: Center(
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('Sign In', style: TextStyle(fontSize: 40))
                  ),
                  AutofillGroup(
                    child: Column(
                      children: [
                        TextField(
                          controller: usernameController,
                          autofillHints: const [AutofillHints.username],
                          decoration: InputDecoration(
                            labelText: 'Username',
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
                            focusColor: Theme.of(context).inputDecorationTheme.focusColor,
                          ),

                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) => login(),
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
                            focusColor: Theme.of(context).inputDecorationTheme.focusColor,
                          ),

                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) => login(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: FilledButton(
                      onPressed:  () => login(),
                      child: const Text('Sign-In'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}