import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:oes/src/AppSecurity.dart';
import 'package:oes/src/services/NetworkChecker.dart';
import 'package:oes/ui/main/course/CourseEditScreen.dart';
import 'package:oes/ui/main/course/CourseHomeworkScreen.dart';
import 'package:oes/ui/main/course/CourseQuizScreen.dart';
import 'package:oes/ui/main/course/CourseScreen.dart';
import 'package:oes/ui/main/MainScreen.dart';
import 'package:oes/ui/main/UserDetailScreen.dart';
import 'package:oes/ui/main/course/CourseTestScreen.dart';
import 'package:oes/ui/main/course/CourseUserQuizScreen.dart';
import 'package:oes/ui/network/NoApiScreen.dart';
import 'package:oes/ui/network/NoInternetScreen.dart';
import 'package:oes/ui/security/Sign-In.dart';
import 'package:oes/ui/security/Sign-Out.dart';
import 'package:oes/ui/test/TestScreen.dart';
import 'package:oes/ui/web/WebHomeScreen.dart';

class AppRouter {

  static final instance = AppRouter._();
  AppRouter._() {
    authCheckRedirect = (context, state) {
      if (_authListener == null) {
        _setAuthListener();
      }
      // Check if Active redirect
      String uriNoParams = state.uri.toString().split('?')[0];
      if (uriNoParams != state.matchedLocation) return null;

      if (!AppSecurity.instance.isInit) return null;
      if (AppSecurity.instance.isLoggedIn()) return null;

      debugPrint('Redirecting to Sign-In Page (User Not LoggedIn)');
      return '/sign-in?path=${state.uri}';
    };

    removeAuthRedirect = (context, state) {
      _removeAuthListener();
      return null;
    };
  }

  String _activeUri = '/';
  String get activeUri => _activeUri;
  bool disableNetworkCheck = false;
  Function()? _authListener;
  late GoRouterRedirect authCheckRedirect;
  late GoRouterRedirect removeAuthRedirect;

  late final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: '/',
        redirect: (context, state) {
          removeAuthRedirect(context, state);
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
        redirect: removeAuthRedirect,
        builder: (context, state) {
          _setActiveUri(context, state);
          return SignIn(path: state.uri.queryParameters['path'] ?? '/');
        },
      ),
      GoRoute(
        path: '/sign-out',
        name: 'sign-out',
        redirect: removeAuthRedirect,
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
            path: 'edit/:course_id',
            name: 'course-edit',
            redirect: authCheckRedirect,
            builder: (context, state) {
              _setActiveUri(context, state);
              int id = int.parse(state.pathParameters['course_id'] ?? '-1');
              return CourseEditScreen(courseId: id);
            },
          ),
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
                path: 'course-test/:test_id/:password',
                name: 'course-test',
                redirect: authCheckRedirect,
                builder: (context, state) {
                  _setActiveUri(context, state);
                  int courseId = int.parse(state.pathParameters['course_id'] ?? '-1');
                  int id = int.parse(state.pathParameters['test_id'] ?? '-1');
                  String password = state.pathParameters['password'] ?? '';
                  return CourseTestScreen(
                    courseId: courseId,
                    testId: id,
                    password: password,
                  );
                },
              ),
              GoRoute(
                path: 'course-quiz/:quiz_id',
                name: 'course-quiz',
                redirect: authCheckRedirect,
                builder: (context, state) {
                  _setActiveUri(context, state);
                  int courseId = int.parse(state.pathParameters['course_id'] ?? '-1');
                  int id = int.parse(state.pathParameters['quiz_id'] ?? '-1');
                  return CourseQuizScreen(
                    courseId: courseId,
                    quizId: id,
                  );
                },
              ),
              GoRoute(
                path: 'course-user-quiz/:quiz_id',
                name: 'course-user-quiz',
                redirect: authCheckRedirect,
                builder: (context, state) {
                  _setActiveUri(context, state);
                  int courseId = int.parse(state.pathParameters['course_id'] ?? '-1');
                  int id = int.parse(state.pathParameters['quiz_id'] ?? '-1');
                  return CourseUserQuizScreen(
                    courseId: courseId,
                    quizId: id,
                  );
                },
              ),
              GoRoute(
                path: 'course-homework/:homework_id',
                name: 'course-homework',
                redirect: authCheckRedirect,
                builder: (context, state) {
                  _setActiveUri(context, state);
                  int courseId = int.parse(state.pathParameters['course_id'] ?? '-1');
                  int id = int.parse(state.pathParameters['homework_id'] ?? '-1');
                  return CourseHomeworkScreen(
                    courseId: courseId,
                    homeworkId: id,
                  );
                },
              )
            ],
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
        redirect: removeAuthRedirect,
        builder: (context, state) {
          return NoInternetScreen(path: state.uri.queryParameters['path'] ?? '/');
        },
      ),
      GoRoute(
        path: '/no-api',
        name: 'no-api',
        redirect: removeAuthRedirect,
        builder: (context, state) {
          return NoApiScreen(path: activeUri);
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

  void _setAuthListener() {
    _authListener = () {
      if (!AppSecurity.instance.isInit) return;
      if (!AppSecurity.instance.isLoggedIn()) {
        debugPrint('Redirecting to Sign-In Page (User Not LoggedIn) [Listener]');
        AppRouter.instance.router.goNamed('sign-in', queryParameters: {
          'path': AppRouter.instance.activeUri,
        });
      }
    };
    if (_authListener != null) AppSecurity.instance.addListener(_authListener!);
  }

  void _removeAuthListener() {
    if (_authListener != null) AppSecurity.instance.removeListener(_authListener!);
    _authListener = null;
  }

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