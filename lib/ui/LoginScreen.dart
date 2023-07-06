import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    bool success = await AppSecurity.instance?.login(usernameController.text, passwordController.text) ?? false;
    if (success) {
      openHome();
    }
    else {
      debugPrint('Invalid Username or Password');
    }
  }

  void openHome() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const HomeScreen(title: 'Title',)
        )
    );

    // Clears All until HomePage
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const HomeScreen(title: 'Title')
        ),
        (Route<dynamic> route) => false
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).primaryColorLight,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 150,
              ),
              child: Column(
                children: [
                  AutofillGroup(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: TextField(
                            controller: usernameController,
                            obscureText: false,
                            enableSuggestions: true,
                            autocorrect: true,

                            keyboardType: TextInputType.name,
                            autofillHints: const [AutofillHints.username],

                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,

                            keyboardType: TextInputType.visiblePassword,
                            autofillHints: const [AutofillHints.password],
                            onEditingComplete: () => TextInput.finishAutofillContext(),

                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text('Login'),
                        onPressed: () => login(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
