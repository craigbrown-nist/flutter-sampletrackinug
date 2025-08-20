import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../API.dart';
import '../../../ListPage.dart';
import '../../../Login.dart';
import '../../../models/User.dart';
import '../auth_repository.dart';

/// This widget acts as a router, deciding which screen to show based on the
/// authentication state. It also handles the initial loading of the JWT from
/// storage, and provides a global listener to catch authentication errors.
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for authentication errors from any provider that depends on currentUserProvider.
    // This acts as a global error handler for expired JWTs.
    ref.listen<AsyncValue<User?>>(currentUserProvider, (_, next) {
      if (next.hasError && next.error is UnauthorizedException) {
        // Use a post-frame callback to safely trigger logout and navigation
        // after the current build cycle is complete.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
             ref.read(authRepositoryProvider).logout();
             // The GoRouter setup will see the auth state change and redirect automatically.
             // A manual context.go('/') might be needed if issues persist.
          }
        });
      }
    });

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
