import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/services/NetworkChecker.dart';
import 'package:oes/ui/main/course/CourseHomeworkScreen.dart';
import 'package:oes/ui/main/course/CourseQuizScreen.dart';
import 'package:oes/ui/main/course/CourseScreen.dart';
import 'package:oes/ui/main/MainScreen.dart';
import 'package:oes/ui/main/UserDetailScreen.dart';
import 'package:oes/ui/main/course/CourseTestScreen.dart';
import 'package:oes/ui/network/NoInternetScreen.dart';
import 'package:oes/ui/security/Sign-In.dart';
import 'package:oes/ui/security/Sign-Out.dart';
import 'package:oes/ui/test/TestScreen.dart';
import 'package:oes/ui/web/WebHomeScreen.dart';

class AppRouter {

  static final instance = AppRouter._();
  AppRouter._();

  String _activeUri = '/';
  String get activeUri => _activeUri;
  bool disableNetworkCheck = false;

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
          _setActiveUri(context, state);
          return const WebHomeScreen();
        },
      ),
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) {
          _setActiveUri(context, state);
          return SignIn(path: state.uri.queryParameters['path'] ?? '/');
        },
      ),
      GoRoute(
        path: '/sign-out',
        name: 'sign-out',
        builder: (context, state) {
          _setActiveUri(context, state);
          return const SignOut();
        },
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        redirect: authCheckRedirect,
        builder: (context, state) {
          _setActiveUri(context, state);
          return const MainScreen();
        },
        routes: [
          GoRoute(
            path: 'test',
            name: 'test',
            // redirect: (context, state) {
            //   if (kReleaseMode){
            //     debugPrint('This is Release so redirecting to Home');
            //     return '/';
            //   }
            //   return null;
            // },
            builder: (context, state) {
              _setActiveUri(context, state);
              return const TestScreen();
            },
          ),
          GoRoute(
            path: 'course/:course_id',
            name: 'course',
            redirect: authCheckRedirect,
            builder: (context, state) {
              _setActiveUri(context, state);
              int id = int.parse(state.pathParameters['course_id'] ?? '-1');
              return CourseScreen(courseID: id);
            },
            routes: [
              GoRoute(
                path: 'course-test/:test_id',
                name: 'course-test',
                redirect: authCheckRedirect,
                builder: (context, state) {
                  _setActiveUri(context, state);
                  int id = int.parse(state.pathParameters['test_id'] ?? '-1');
                  return CourseTestScreen(testId: id);
                },
              ),
              GoRoute(
                path: 'course-quiz/:quiz_id',
                name: 'course-quiz',
                redirect: authCheckRedirect,
                builder: (context, state) {
                  _setActiveUri(context, state);
                  int id = int.parse(state.pathParameters['quiz_id'] ?? '-1');
                  return CourseQuizScreen(quizId: id);
                },
              ),
              GoRoute(
                path: 'course-homework/:homework_id',
                name: 'course-homework',
                redirect: authCheckRedirect,
                builder: (context, state) {
                  _setActiveUri(context, state);
                  int id = int.parse(state.pathParameters['homework_id'] ?? '-1');
                  return CourseHomeworkScreen(homeworkId: id);
                },
              )
            ],
          ),
          GoRoute(
            path: 'mobile-web',
            name: 'mobile-web',
            builder: (context, state) {
              _setActiveUri(context, state);
              return const WebHomeScreen();
            },
          ),
          GoRoute(
            path: 'user-detail',
            name: 'user-detail',
            redirect: authCheckRedirect,
            builder: (context, state) {
              _setActiveUri(context, state);
              return const UserDetailScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/no-internet',
        name: 'no-internet',
        builder: (context, state) {
          _setActiveUri(context, state);
          return NoInternetScreen(path: state.uri.queryParameters['path'] ?? '/');
        },
      ),
    ],

    observers: [ _RouterObserver() ],
  );

  void _setActiveUri(BuildContext context, GoRouterState state) {
    // Check if Active uri
    String uriNoParams = state.uri.toString().split('?')[0];
    if (uriNoParams != state.matchedLocation) return;

    // Check if is not No Internet Screen
    if (state.uri.toString().contains('no-internet')) return;

    // Save Active uri
    _activeUri = state.uri.toString();
  }

  GoRouterRedirect authCheckRedirect = (context, state) {
    // Check if Active redirect
    String uriNoParams = state.uri.toString().split('?')[0];
    if (uriNoParams != state.matchedLocation) return null;

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
      Function() listener = () { };
      listener = () {
        if(context.mounted){
          if (!AppSecurity.instance.isLoggedIn()) {
            debugPrint('Redirecting to Sign-In Page (User Not LoggedIn) [Listener]');
            AppRouter.instance.router.goNamed('sign-in', queryParameters: {
              'path': state.uri,
            });
          }
        }
        AppSecurity.instance.removeListener(listener);
      };
      AppSecurity.instance.addListener(listener);
    });

    return null;
  };

  void setNetworkListener() {
    listener() {
      var networkChecker = NetworkChecker.instance;
      if (networkChecker.isInit && !networkChecker.haveInternet) {
        if (disableNetworkCheck) return;
        debugPrint('Redirecting to No Internet Page');
        router.goNamed('no-internet', queryParameters: {
          'path': _activeUri,
        });
      }
    }
    NetworkChecker.instance.addListener(listener);
    NetworkChecker.instance.checkConnection();
  }
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