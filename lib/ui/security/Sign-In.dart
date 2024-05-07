import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Organization.dart';
import 'package:oes/src/restApi/interface/OrganizationGateway.dart';
import 'package:oes/ui/assets/buttons/SettingButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/PopupDialog.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';

class SignIn extends StatefulWidget {
  const SignIn({this.path = '/', super.key});

  final String path;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  String path = "/";
  Organization? organization;

  @override
  void initState() {
    if (path.contains('sign-out')) {
      path = '/';
    } else {
      path = widget.path;
    }
    organization = AppApi.instance.organization;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ? Orientation.landscape : Orientation.portrait;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                padding: const EdgeInsets.all(50),
                margin: const EdgeInsets.all(20),
                child: Builder(
                  builder: (context) {
                    if (organization == null) {
                      return _OrganizationSelector(
                        organization: organization,
                        orientation: orientation,
                        onSelected: (organization) {
                          setState(() {
                            this.organization = organization;
                            AppApi.instance.setOrganization(organization);
                          });
                        },
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Login(
                          path: path,
                          orientation: orientation,
                          onSelectOrganization: () {
                            setState(() {
                              organization = null;
                            });
                          },
                        ),
                      ],
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

class _OrganizationSelector extends StatefulWidget {
  const _OrganizationSelector({
    required this.organization,
    required this.onSelected,
    required this.orientation,
    super.key
  });

  final Organization? organization;
  final Function(Organization organization) onSelected;
  final Orientation orientation;

  @override
  State<_OrganizationSelector> createState() => _OrganizationSelectorState();
}

class _OrganizationSelectorState extends State<_OrganizationSelector> {

  TextEditingController filterController = TextEditingController();

  @override
  void dispose() {
    filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.orientation == Orientation.landscape ? 800 : 400,
        maxHeight: 500,
      ),
      child: Column(
        children: [
          const Text('Organizations', style: TextStyle(fontSize: 35)),
          Flexible(
            child: FutureBuilder(
              future: OrganizationGateway.instance.getAll(filterController.text),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const WidgetLoading();
                List<Organization> organizations = snapshot.data!;
                return ListView.builder(
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    Organization organization = organizations[index];
                    return IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Button(
                          text: organization.name,
                          toolTip: organization.url,
                          minHeight: 50,
                          maxHeight: double.infinity,
                          onClick: (context) {
                            widget.onSelected(organization);
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            ),
          ),
          TextField(
            controller: filterController,
            decoration: const InputDecoration(
              labelText: "Search"
            ),
            onChanged: (value) {
              setState(() {});
            },
          )
        ],
      ),
    );
  }
}

class _Login extends StatefulWidget {
  const _Login({
    required this.path,
    required this.onSelectOrganization,
    required this.orientation,
    super.key
  });

  final String path;
  final Function() onSelectOrganization;
  final Orientation orientation;

  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = true;
  bool signing = false;
  bool wrongPassword = false;

  Future<void> login(String username, String password, bool rememberMe) async {
    setState(() {
      signing = true;
    });

    bool success = await AppSecurity.instance.login(
      username,
      password,
      rememberMe: rememberMe,
    );

    if (!success) {
      debugPrint('Invalid Username or Password');

      if (context.mounted) {
        setState(() {
          wrongPassword = true;
        });
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            wrongPassword = false;
          });
        },);
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
      context.go(widget.path);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.orientation == Orientation.landscape ? 800 : 400,
      ),
      child: Builder(builder: (context) {
        // Portrait
        if (widget.orientation == Orientation.portrait) {
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
                      orientation: widget.orientation,
                      value: rememberMe,
                      onRememberChanged: (rememberMe) {
                        this.rememberMe = rememberMe;
                      },
                    ),
                    const SizedBox(height: 5,),
                    _LoginButton(
                      wrongPassword: wrongPassword,
                      loginFunction: () {
                        login(usernameController.text, passwordController.text, rememberMe);
                      },
                      signing: signing,
                    ),
                    const SizedBox(height: 10,),
                    Button(
                      text: "Select Organization",
                      maxWidth: double.infinity,
                      onClick: (context) {
                        widget.onSelectOrganization();
                      },
                    )
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
                        login(usernameController.text, passwordController.text, rememberMe);
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
                      orientation: widget.orientation,
                      value: rememberMe,
                      onRememberChanged: (rememberMe) {
                        this.rememberMe = rememberMe;
                      },
                    ),
                    const SizedBox(height: 5,),
                    _LoginButton(
                      wrongPassword: wrongPassword,
                      loginFunction: () {
                        login(usernameController.text, passwordController.text, rememberMe);
                      },
                      signing: signing,
                    ),
                    const SizedBox(height: 10,),
                    Button(
                      text: "Select Organization",
                      maxWidth: double.infinity,
                      onClick: (context) {
                        widget.onSelectOrganization();
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}



class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.loginFunction,
    required this.signing,
    required this.wrongPassword,
    super.key,
  });

  final Function() loginFunction;
  final bool signing;
  final bool wrongPassword;

  @override
  Widget build(BuildContext context) {
    return Button(
      maxWidth: double.infinity,
      text: 'Sign-In',
      backgroundColor: wrongPassword ? Colors.red.shade700 : null,
      onClick: (context) => loginFunction(),
      child: !signing ? null : SizedBox(
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
          ],
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildRememberMe(context),
        ],
      );
    }
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
