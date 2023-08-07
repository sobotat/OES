import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:oes/ui/main/CourseScreen.dart';
import 'package:oes/ui/main/MainScreen.dart';
import 'package:oes/ui/main/UserDetailScreen.dart';
import 'package:oes/ui/security/Sign-In.dart';
import 'package:oes/ui/security/Sign-Out.dart';
import 'package:oes/ui/web/WebHomeScreen.dart';

import '../src/AppSecurity.dart';

class AppRouter {

  static final instance = AppRouter();

  GoRouterRedirect authCheckRedirect = (context, state) {
    // Check if Active redirect
    if (state.uri.toString() != state.matchedLocation) return null;

    // Check user if is Init
    if(AppSecurity.instance.isInit) {
      if (!AppSecurity.instance.isLoggedIn()) {
        debugPrint('Redirecting to Sign-In Page (User Not LoggedIn)');
        return '/sign-in?path=${state.uri}';
      }
      return null;
    }

    // If not Init will wait for Init
    Future.delayed(Duration.zero, () {
     listener() {
       if(context.mounted){
         if (!AppSecurity.instance.isLoggedIn()) {
           debugPrint('Redirecting to Sign-In Page (User Not LoggedIn)');
           AppRouter.instance.router.go('/sign-in?path=${state.uri}');
         }
       }
     }
     AppSecurity.instance.addListener(listener);
    });

    return null;
  };

  late final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: '/',
        redirect: (context, state) {
          if (!kIsWeb) {
            return '/main';
          }
          return null;
        },
        builder: (context, state) {
          return const WebHomeScreen();
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
          Future.delayed(const Duration(milliseconds: 100), () {
            AppSecurity.instance.logout();
          });
          return const SignOut();
        },
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        redirect: authCheckRedirect,
        builder: (context, state) {
          return const MainScreen();
        },
        routes: [
          GoRoute(
            path: 'course/:id',
            name: 'course',
            redirect: authCheckRedirect,
            builder: (context, state) {
              int id = int.parse(state.pathParameters['id'] ?? '-1');
              return CourseScreen(courseID: id);
            },
          ),
          GoRoute(
            path: 'test',
            name: 'test',
            builder: (context, state) {
              return const WebHomeScreen();
            },
          ),
          GoRoute(
            path: 'user-detail',
            name: 'user-detail',
            redirect: authCheckRedirect,
            builder: (context, state) {
              return const UserDetailScreen();
            },
          ),
        ],
      ),
    ],

    observers: [ _RouterObserver() ],
  );
}

class _RouterObserver extends NavigatorObserver {

  // Check on Pop (On going back)
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    Future.delayed(const Duration(milliseconds: 100), () {
      AppRouter.instance.router.refresh();
    });
  }
}