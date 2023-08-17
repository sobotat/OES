
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oes/src/restApi/api/TestApi.dart';
import 'package:oes/ui/assets/dialogs/SmallMenu.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});
  
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  int? number;
  bool loadingNumber = false;
  List<String> users = [];
  bool loadingUser = false;

  @override
  void initState() {
    super.initState();
    loadNumber();
    loadUser();
  }

  Future<void> loadNumber() async {
    setState(() { loadingNumber = true; });
    number = await TestApi.number(Random().nextInt(100));
    setState(() { loadingNumber = false; });
  }

  Future<void> loadUser() async {
    setState(() { loadingUser = true; });
    users = await TestApi.users();
    setState(() { loadingUser = false; });
  }
  
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
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => loadNumber(),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[700],
                  ),
                  width: 300,
                  height: 100,
                  child: Align(
                    alignment: Alignment.center,
                    child: !loadingNumber ? Text('Number is ${number ?? 'API Failed'}') : const CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => loadUser(),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal[300],
                  ),
                  width: 300,
                  height: 100,
                  child: Align(
                    alignment: Alignment.center,
                    child: !loadingUser ? ListView.builder(
                      itemCount: users.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Center(child: Text(users[index]));
                      },
                    ) : const CircularProgressIndicator(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}