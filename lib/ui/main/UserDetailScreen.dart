import 'package:flutter/material.dart';
import 'package:oes/config/AppIcons.dart';
import 'package:oes/config/AppTheme.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/objects/SignedDevice.dart';
import 'package:oes/ui/assets/buttons/Sign-OutButton.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';
import 'package:oes/ui/assets/templates/Button.dart';
import 'package:oes/ui/assets/widgets/SignedDeviceWidget.dart';

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
      body: SafeArea(
        child: LayoutBuilder(
            builder: (context, constrain) {
              if (constrain.maxWidth <= 550) {
                return ListView(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: _ProfilePhoto(),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.only(bottom: 10),
                      child: _UserInfo(),
                    ),
                    const SizedBox(
                      height: 500,
                      child: _Devices(),
                    ),
                  ],
                );
              }
              else {
                return Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(10),
                          child: _UserInfo(),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              margin: EdgeInsets.all(10),
                              alignment: Alignment.center,
                              child: _ProfilePhoto(),
                            ),
                            const Expanded(
                              child: _Devices(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }
            }
        ),
      ),
    );
  }
}

class _Devices extends StatelessWidget {
  const _Devices({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary,
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: ListenableBuilder(
        listenable: AppSecurity.instance,
        builder: (context, widget) {
          return FutureBuilder<List<SignedDevice>?>(
            future: AppSecurity.instance.isLoggedIn() ? AppSecurity.instance.user!.getSignedDevices() : Future(() => []),
            builder: (context, snapshot) {
              return snapshot.hasData ? ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: SignedDeviceWidget(
                      signedDevice: snapshot.data![index],
                    ),
                  );
                },
              ) : const Center(child: CircularProgressIndicator());
            }
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

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FirstName(firstNameController: _firstNameController),
            _LastName(lastNameController: _lastNameController),
            _Username(usernameController: _usernameController),
            _Password(passwordController: _passwordController)
          ],
        );
      },
    );
  }
}

class _Password extends StatelessWidget {
  const _Password({
    required this.passwordController,
  });

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 5,
      ),
      child: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          label: Text('Password'),
        ),
      ),
    );
  }
}

class _Username extends StatelessWidget {
  const _Username({
    required this.usernameController,
  });

  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 5,
      ),
      child: TextField(
        controller: usernameController,
        decoration: const InputDecoration(
          label: Text('Username'),
        ),
      ),
    );
  }
}

class _FirstName extends StatelessWidget {
  const _FirstName({
    required this.firstNameController,
  });

  final TextEditingController firstNameController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 5,
      ),
      child: TextField(
        controller: firstNameController,
        decoration: const InputDecoration(
          label: Text('First Name')
        ),
      ),
    );
  }
}

class _LastName extends StatelessWidget {
  const _LastName({
    required this.lastNameController,
  });

  final TextEditingController lastNameController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 5,
      ),
      child: TextField(
        controller: lastNameController,
        decoration: const InputDecoration(
            label: Text('Last Name')
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
          color: counter < 4 ? AppTheme.isDarkMode() ? Colors.grey[300] : Colors.grey[700] : Colors.lightBlue,
        )
      )
    );
  }
}