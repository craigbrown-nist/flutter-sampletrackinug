import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../API.dart';
import '../../../ListPage.dart';
import '../../../Login.dart';
import '../../../models/User.dart';
import '../../../router.dart';
import '../../samples/sample_providers.dart';
import '../auth_repository.dart';

/// This widget acts as a router, deciding which screen to show based on the
/// authentication state. It also handles the initial loading of the JWT from
/// storage, and provides a global listener to catch authentication errors.
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Helper function to avoid duplicating the listener logic.
    void createAuthErrorListener<T>(ProviderListenable<AsyncValue<T>> provider) {
      ref.listen<AsyncValue<T>>(provider, (_, next) {
        if (next.hasError && next.error is UnauthorizedException) {
          // When an auth error occurs, log the user out and navigate to the login screen.
          // We use the navigatorKey to get a valid context, then find the GoRouter
          // instance to perform the navigation safely.
          ref.read(authRepositoryProvider).logout();
          final context = navigatorKey.currentContext;
          if (context != null) {
            GoRouter.of(context).go('/login');
          }
        }
      });
    }

    // Create listeners for all providers that can throw an UnauthorizedException.
    // This was the missing piece in the previous attempt.
    createAuthErrorListener(currentUserProvider);
    createAuthErrorListener(userSamplesProvider);
    createAuthErrorListener(allSamplesProvider);

    // Watch the app initialization provider.
    final appInit = ref.watch(appInitProvider);

    return appInit.when(
      // Show a loading screen while the JWT is being loaded.
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      // Show an error screen if initialization fails.
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error initializing app: $error'),
        ),
      ),
      // When initialization is complete, decide which screen to show.
      data: (_) {
        // Watch the auth state provider.
        final authState = ref.watch(authStateProvider);
        // If the user is authenticated, show the home screen.
        // Otherwise, show the login screen.
        return authState != null ? const ListPage() : const Login();
      },
    );
  }
}
