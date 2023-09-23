import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/assets/buttons/SettingButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';

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
  bool rememberMe = true;
  bool signing = false;

  Future<void> login() async {
    setState(() {
      signing = true;
    });

    bool success = await AppSecurity.instance.login(
        usernameController.text,
        passwordController.text,
        rememberMe: rememberMe,
    );

    if (!success) {
      debugPrint('Invalid Username or Password');

      if (context.mounted) {
        _showSignFailedDialog();
      }

      setState(() {
        signing = false;
      });
      return;
    }

    if (context.mounted) {
      setState(() {
        signing = false;
      });
      context.go(path);
    }
  }

  Future<dynamic> _showSignFailedDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return PopupDialog(
          alignment: Alignment.center,
          child: Material(
            elevation: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.secondary,
              ),
              width: 300,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Wrong Password or Username'),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Button(
                      maxWidth: double.infinity,
                      onClick: (context) { context.pop(); },
                      text: 'Close',
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var shortest = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 25,
              ),
              child: Align(
                alignment: Alignment.center,
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(shortest > 500 ? 50 : 25),
                        width: orientation == Orientation.landscape ? 800 : 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Builder(builder: (context) {
                          // Portrait
                          if (orientation == Orientation.portrait) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _Heading(),
                                _Input(
                                  usernameController: usernameController,
                                  passwordController: passwordController,
                                  loginFunction: () {

                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      _RememberAndReset(
                                        orientation: orientation,
                                        value: rememberMe,
                                        onRememberChanged: (rememberMe) {
                                          this.rememberMe = rememberMe;
                                        },
                                      ),
                                      const SizedBox(height: 5,),
                                      _LoginButton(
                                        loginFunction: login,
                                        signing: signing,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          // Landscape
                          else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(child: _Heading()),
                                    Expanded(
                                      flex: 2,
                                      child: _Input(
                                        usernameController: usernameController,
                                        passwordController: passwordController,
                                        loginFunction: () {

                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 40,
                                    bottom: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      _RememberAndReset(
                                        orientation: orientation,
                                        value: rememberMe,
                                        onRememberChanged: (rememberMe) {
                                          this.rememberMe = rememberMe;
                                        },
                                      ),
                                      const SizedBox(height: 5,),
                                      _LoginButton(
                                        loginFunction: login,
                                        signing: signing,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeModeButton(),
                  SettingButton()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatefulWidget {
  const _LoginButton({
    required this.loginFunction,
    required this.signing,
    super.key,
  });

  final Function() loginFunction;
  final bool signing;

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {

  @override
  Widget build(BuildContext context) {
    return Button(
      maxWidth: double.infinity,
      text: 'Sign-In',
      onClick: (context) => widget.loginFunction(),
      child: !widget.signing ? null : SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Theme.of(context).extension<AppCustomColors>()!.accent,
        ),
      ),
    );
  }
}

class _RememberAndReset extends StatefulWidget {
  const _RememberAndReset({
    required this.orientation,
    required this.value,
    required this.onRememberChanged,
    super.key,
  });

  final Orientation orientation;
  final bool value;
  final Function(bool rememberMe) onRememberChanged;

  @override
  State<_RememberAndReset> createState() => _RememberAndResetState();
}

class _RememberAndResetState extends State<_RememberAndReset> {

  bool rememberMe = false;
  @override
  void initState() {
    super.initState();
    rememberMe = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orientation == Orientation.portrait) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: buildRememberMe(context)),
            const SizedBox(height: 5,),
            Center(child: buildResetPassword(context)),
          ],
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildRememberMe(context),
          buildResetPassword(context),
        ],
      );
    }
  }

  Widget buildResetPassword(BuildContext context) {
    return RichText(
        text: TextSpan(
          text: 'Reset Password',
          style: TextStyle(color: AppTheme.isDarkMode() ? Colors.grey : Colors.grey[800]),
          recognizer: TapGestureRecognizer()..onTap = () {
            debugPrint('Not Implemented');
            //TODO: Implement
          },
        ),
      );
  }

  Widget buildRememberMe(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: rememberMe,
          activeColor: Theme.of(context).extension<AppCustomColors>()!.accent,
          onChanged: (value) {
            setState(() {
              rememberMe = !rememberMe;
              widget.onRememberChanged(rememberMe);
            });
          },
        ),
        Text('Remember Me',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: rememberMe ? Theme.of(context).extension<AppCustomColors>()!.accent : AppTheme.isDarkMode() ? Colors.grey : Colors.grey[800]
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.all(30),
        child: Text('Sign In', style: TextStyle(fontSize: 40))
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.usernameController,
    required this.passwordController,
    required this.loginFunction,
    super.key
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final Function() loginFunction;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          TextField(
            controller: usernameController,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Username',
            ),

            textInputAction: TextInputAction.go,
            onSubmitted: (value) => loginFunction(),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(
              labelText: 'Password',
            ),

            textInputAction: TextInputAction.go,
            onSubmitted: (value) => loginFunction(),
          ),
        ],
      ),
    );
  }
}
