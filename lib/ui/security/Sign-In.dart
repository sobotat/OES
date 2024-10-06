import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:oes/config/AppApi.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/Organization.dart';
import 'package:oes/src/restApi/interface/OrganizationGateway.dart';
import 'package:oes/ui/assets/buttons/BackToWeb.dart';
import 'package:oes/ui/assets/buttons/SettingButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/dialogs/LoadingDialog.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/templates/IconItem.dart';
import 'package:oes/ui/assets/templates/WidgetLoading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
        child: Column(
          children: [
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
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.all(10),
                constraints: const BoxConstraints(
                  maxWidth: 800,
                ),
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
                    return _Login(
                      path: path,
                      orientation: orientation,
                      onSelectOrganization: () {
                        setState(() {
                          organization = null;
                        });
                      },
                    );
                  },
                ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select your', style: TextStyle(fontSize: 20)
            ),
            Text(
              'Organizations', style: TextStyle(fontSize: 30)
            ),
          ],
        ),
        const SizedBox(height: 30,),
        TextField(
          controller: filterController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: "Search"
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondary
            ),
            child: FutureBuilder(
              future: OrganizationGateway.instance.getAll(filterController.text),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const WidgetLoading();
                List<Organization> organizations = snapshot.data!;
                return ListView.builder(
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    Organization organization = organizations[index];
                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: IconItem(
                        icon: const Icon(Icons.add_business_rounded),
                        body: Text(organization.name),
                        color: Theme.of(context).extension<AppCustomColors>()!.accent,
                        padding: EdgeInsets.zero,
                        onClick: (context) {
                          widget.onSelected(organization);
                        },
                        onHold: (context) {
                          showAdaptiveDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) {
                              return AlertDialog.adaptive(
                                title: const Text("Organization Info"),
                                content: Text("URL: ${organization.url}"),
                                actions: [
                                  TextButton(
                                    child: const Text("Ok"),
                                    onPressed: () {
                                      if(mounted) context.pop();
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }
            ),
          ),
        )
      ],
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
  bool wrongPassword = false;

  Future<void> login(String username, String password) async {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );

    bool success = await AppSecurity.instance.login(username,password,);

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

      if(mounted) context.pop();
      return;
    }

    if (mounted) {
      context.pop();
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
    return Builder(builder: (context) {
      // Portrait
      if (widget.orientation == Orientation.portrait) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Heading(),
            const SizedBox(height: 30,),
            _Input(
              usernameController: usernameController,
              passwordController: passwordController,
              loginFunction: () {

              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 10
              ),
              child: Column(
                children: [
                  _LoginButton(
                    wrongPassword: wrongPassword,
                    loginFunction: () {
                      login(usernameController.text, passwordController.text);
                    },
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
                      login(usernameController.text, passwordController.text);
                    },
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 10,
              ),
              child: Column(
                children: [
                  _LoginButton(
                    wrongPassword: wrongPassword,
                    loginFunction: () {
                      login(usernameController.text, passwordController.text);
                    },
                  ),
                  const SizedBox(height: 10,),
                  Button(
                    icon: Icons.home_work_rounded,
                    text: "Back to Organizations",
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
    });
  }
}



class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.loginFunction,
    required this.wrongPassword,
    super.key,
  });

  final Function() loginFunction;
  final bool wrongPassword;

  @override
  Widget build(BuildContext context) {
    return Button(
      maxWidth: double.infinity,
      text: 'Sign-In',
      icon: Icons.login,
      backgroundColor: wrongPassword ? Colors.red.shade700 : null,
      onClick: (context) => loginFunction(),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sign In', style: TextStyle(fontSize: 30)
            ),
            Text(
              'To Your Profile', style: TextStyle(fontSize: 20)
            ),
          ],
        ),
      ],
    );
  }
}

class _Input extends StatefulWidget {
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
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {

  bool hiddenPassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary
      ),
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10
      ),
      child: AutofillGroup(
        child: Column(
          children: [
            TextField(
              controller: widget.usernameController,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(
                labelText: 'Username',
              ),

              textInputAction: TextInputAction.go,
              onSubmitted: (value) => widget.loginFunction(),
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: widget.passwordController,
                    obscureText: hiddenPassword,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) => widget.loginFunction(),
                    onChanged: (value) {
                      setState(() {
                        hiddenPassword = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 5,),
                Button(
                  icon: hiddenPassword ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
                  maxWidth: 40,
                  onClick: (context) {
                    setState(() {
                      hiddenPassword = !hiddenPassword;
                    });
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
