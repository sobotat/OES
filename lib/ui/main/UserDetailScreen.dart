import 'package:flutter/material.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';
import 'package:oes/ui/assets/templates/Button.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 0,
            ),
            child: width > overflow ? const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                UserInfoButton(
                  width: 150,
                ),
                SignOutButton(),
                ThemeModeButton(),
              ],
            ) : const SmallMenu(),
          )
        ],
        title: const Text('User Detail'),
      ),
      body: Builder(
        builder: (context) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: _UserInfo()
                ),
              )
            ],
          );
        }
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  _UserInfo();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSecurity.instance,
      builder: (context, child) {
        _firstNameController.text = AppSecurity.instance.user?.firstName ?? '';
        _lastNameController.text = AppSecurity.instance.user?.lastName ?? '';
        _usernameController.text = AppSecurity.instance.user?.username ?? '';
        _passwordController.text = AppSecurity.instance.user == null ? '' : '*****.****.****';

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 50,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondary
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: _ProfilePhoto(),
              ),
              _FirstAndLastNameRow(firstNameController: _firstNameController, lastNameController: _lastNameController),
              _UsernameAndPasswordRow(usernameController: _usernameController, passwordController: _passwordController)
            ],
          ),
        );
      },
    );
  }
}

class _UsernameAndPasswordRow extends StatelessWidget {
  const _UsernameAndPasswordRow({
    required TextEditingController usernameController,
    required TextEditingController passwordController,
  }) : _usernameController = usernameController, _passwordController = passwordController;

  final TextEditingController _usernameController;
  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Column(
      children: [
        width > overflow ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Username(usernameController: _usernameController),
            _Password(passwordController: _passwordController),
          ],
        ) : Container(),
        width > overflow ? Container() : _Username(usernameController: _usernameController, fill: true,),
        width > overflow ? Container() : _Password(passwordController: _passwordController, fill: true,),
      ],
    );
  }
}

class _Password extends StatelessWidget {
  const _Password({
    required this.passwordController,
    this.fill = false,
  });

  final TextEditingController passwordController;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 5,
      ),
      child: FractionallySizedBox(
        widthFactor: fill ? 0.9 : null,
        child: SizedBox(
          width: fill ? null : 200,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              label: Text('Password'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Username extends StatelessWidget {
  const _Username({
    required this.usernameController,
    this.fill = false,
  });

  final TextEditingController usernameController;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 5,
      ),
      child: FractionallySizedBox(
        widthFactor: fill ? 0.9 : null,
        child: SizedBox(
          width: fill ? null : 200,
          child: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              label: Text('Username'),
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstAndLastNameRow extends StatelessWidget {
  const _FirstAndLastNameRow({
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
  }) : _firstNameController = firstNameController, _lastNameController = lastNameController;

  final TextEditingController _firstNameController;
  final TextEditingController _lastNameController;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var overflow = 950;

    return Column(
      children: [
        width > overflow ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FirstName(firstNameController: _firstNameController),
            _LastName(lastNameController: _lastNameController),
          ],
        ) : Container(),
        width > overflow ? Container() : _FirstName(firstNameController: _firstNameController, fill: true),
        width > overflow ? Container() : _LastName(lastNameController: _lastNameController, fill: true),
      ],
    );
  }
}

class _FirstName extends StatelessWidget {
  const _FirstName({
    required this.firstNameController,
    this.fill = false,
  });

  final TextEditingController firstNameController;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 5,
      ),
      child: FractionallySizedBox(
        widthFactor: fill ? 0.9 : null,
        child: SizedBox(
            width: fill ? null : 200,
            child: TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                label: Text('First Name')
              ),
            )
        ),
      ),
    );
  }
}

class _LastName extends StatelessWidget {
  const _LastName({
    required this.lastNameController,
    this.fill = false,
  });

  final TextEditingController lastNameController;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 5,
      ),
      child: FractionallySizedBox(
        widthFactor: fill ? 0.9 : null,
        child: SizedBox(
          width: fill ? null : 200,
          child: TextField(
            controller: lastNameController,
            decoration: const InputDecoration(
                label: Text('Last Name')
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatefulWidget {
  const _ProfilePhoto();

  @override
  State<_ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<_ProfilePhoto> {

  int counter = 0;
  IconData icon = AppIcons.icon_profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: GestureDetector(
        onTap: () {
          setState(() {
            counter += 1;
            if (counter < 3) {
              return;
            }

            if (counter == 3) {
              icon = Icons.ac_unit;
              return;
            }

            if (counter < 5 || icon == AppIcons.icon_teapot) {
              return;
            }

            showDialog<String>(
                context: context,
                builder: (BuildContext context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.all(5),
                          child: Text('Are you a teapot?'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Button(
                            text: 'Yes I\'m',
                            maxWidth: 150,
                            onClick: (context) {
                              Navigator.pop(context);
                              setState(() {
                                icon = AppIcons.icon_teapot;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ));

          });
        },
        child: Icon(
          icon,
          size: 200,
          color: counter < 4 ? Colors.white : Colors.lightBlue,
        )
      )
    );
  }
}