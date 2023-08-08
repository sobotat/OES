
import 'package:flutter/material.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 0,
            ),
            child: const SmallMenu(),
          )
        ],
      ),
      body: const Placeholder(),
    );
  }
}
