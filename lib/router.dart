import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_repository.dart';
import 'features/auth/presentation/auth_checker.dart';

// Import the page widgets here
import 'Login.dart';
import 'ListPage.dart';
import 'features/users/presentation/users_page.dart';
import 'UI/CellsPage.dart';
import 'UI/EmptyPage.dart';
import 'UI/AllPage.dart';
import 'UI/ScannerPage.dart';
import 'UI/ScannerWinPage.dart';
import 'UI/Printer.dart';
import 'UI/about.dart';

/// Provider to create the GoRouter instance.
/// We use a provider so that the router can read other providers, for example
/// to get the authentication state.
final routerProvider = Provider<GoRouter>((ref) {
  // By watching the authStateProvider, the router will automatically rebuild
  // and re-evaluate redirects whenever the authentication state changes.
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Log navigation events to the console
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthChecker(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: '/myhome',
        builder: (context, state) => const ListPage(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UsersPage(),
      ),
      GoRoute(
        path: '/cells',
        builder: (context, state) => const CellsPage(),
      ),
      GoRoute(
        path: '/empty',
        builder: (context, state) => const EmptyPage(),
      ),
      GoRoute(
        path: '/all',
        builder: (context, state) => const AllPage(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScannerPage(),
      ),
      GoRoute(
        path: '/scanWin',
        builder: (context, state) => const ScannerWinPage(),
      ),
      GoRoute(
        path: '/printers',
        builder: (context, state) => const PrinterPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authState != null;
      final loggingIn = state.matchedLocation == '/login';
      final isInitialRoute = state.matchedLocation == '/';

      // If we are on the initial route (AuthChecker), let it handle the logic.
      if (isInitialRoute) {
        return null;
      }

      // If the user is not logged in and not on the login page, redirect to login.
      if (!loggedIn && !loggingIn) {
        return '/login';
      }

      // If the user is logged in and on the login page, redirect to home.
      if (loggedIn && loggingIn) {
        return '/myhome';
      }

      // No redirect needed.
      return null;
    },
  );
});
