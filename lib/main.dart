import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

// local app files
import 'Login.dart';
import 'ListPage.dart';
import 'UI/CellsPage.dart';
import 'UI/EmptyPage.dart';
import 'UI/ScannerPage.dart';
import 'UI/ScannerWinPage.dart';
import 'UI/UsersPage.dart';
import 'UI/AllPage.dart';
import 'UI/Printer.dart';
import 'UI/about.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Samples',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(158, 166, 186, 1.0),
        ),
        useMaterial3: true,
      ),
      // The home screen will be replaced with a router that handles auth state.
      // For now, we leave it as Login() until the auth logic is refactored.
      home: const Login(),
      initialRoute: '/',
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) =>
              const Scaffold(body: Center(child: Text('Not Found'))),
        );
      },
      routes: {
        // These routes will eventually be managed by a router like GoRouter.
        '/myhome': (BuildContext context) => const ListPage(),
        '/cells': (BuildContext context) => const CellsPage(),
        '/empty': (BuildContext context) => const EmptyPage(),
        '/all': (BuildContext context) => const AllPage(),
        '/scan': (BuildContext context) => const ScannerPage(),
        '/scanWin': (BuildContext context) => const ScannerWinPage(),
        '/printers': (BuildContext context) => const PrinterPage(),
        '/about': (BuildContext context) => const AboutPage(),
        '/users': (BuildContext context) => const UsersPage(),
      },
    );
  }
}
