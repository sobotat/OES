import 'package:flutter/material.dart';
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/ui/HomeScreen.dart';
import 'package:oes/ui/LoginScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool initialized = false;

  _MyAppState(){
    AppSecurity appSecurity = AppSecurity();
    appSecurity.init().then((value) {
      setState(() {
        initialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OES',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: initialized ? (AppSecurity.instance?.isLoggedIn() ?? false ? const HomeScreen(title: 'Title') : const LoginScreen()) : const Text('Loading'),
    );
  }
}


