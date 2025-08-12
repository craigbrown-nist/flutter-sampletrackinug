import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

// local app files
import 'router.dart';

// NOTE: This class is intentionally left in based on user requirements
// for an internal network that requires bypassing SSL certificate validation.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // IMPORTANT: The following line bypasses SSL certificate validation.
  // This is a major security risk and should only be used in trusted environments.
  HttpOverrides.global = MyHttpOverrides();

  // Wrap the entire application in a ProviderScope for Riverpod state management.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the router provider to get the GoRouter instance.
    final router = ref.watch(routerProvider);

    // Use MaterialApp.router to integrate GoRouter.
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My Samples',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(158, 166, 186, 1.0),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
