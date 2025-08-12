import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ListPage.dart';
import '../../../Login.dart';
import '../auth_repository.dart';

/// This widget acts as a router, deciding which screen to show based on the
/// authentication state. It also handles the initial loading of the JWT from
/// storage.
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      // In a real app, you might want to handle this more gracefully.
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
