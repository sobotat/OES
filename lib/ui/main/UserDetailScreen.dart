import 'package:flutter/material.dart';
import 'package:oes/ui/assets/buttons/ThemeModeButton.dart';
import 'package:oes/ui/assets/buttons/UserInfoButton.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 2,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  UserInfoButton(
                    width: 150,
                  ),
                  ThemeModeButton(),
                ],
              ),
            )
          ],
          title: Text('User Detail'),
        ),
    );
  }
}
