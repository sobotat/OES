import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:oes/ui/HomeScreen.dart';
import 'package:oes/ui/Sign-In.dart';
import 'package:oes/main.dart';
import 'package:oes/ui/Sign-Out.dart';
import 'package:oes/ui/web/WebHomeScreen.dart';

import '../src/AppSecurity.dart';

class AppRouter {

  static final instance = AppRouter();

  GoRouterRedirect authCheckRedirect = (context, state) {
    if(!AppSecurity.instance.isLoggedIn()) {
      return '/sign-in?path=${state.name}';
    }
    return null;
  };

  late final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: '/',
        redirect: (context, state) {
          if (!kIsWeb) {
            return '/other';
          }
          return null;
        },
        builder: (context, state) {
          return const WebHomeScreen();
        },
      ),
      GoRoute(
        path: '/other',
        name: 'other',
        redirect: authCheckRedirect,
        builder: (context, state) {
          return const OtherMain();
        },
      ),
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) {
          return SignIn(path: state.uri.queryParameters['path'] ?? '/');
        },
      ),
      GoRoute(
        path: '/sign-out',
        name: 'sign-out',
        builder: (context, state) {
          AppSecurity.instance.logout();
          return const SignOut();
        },
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        redirect: authCheckRedirect,
        builder: (context, state) {
          return const HomeScreen(title: 'Main');
        },
      ),
    ],
  );
}