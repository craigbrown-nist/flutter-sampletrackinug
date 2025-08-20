import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../API.dart';
import '../../Functions/Server.dart';
import '../../models/User.dart';
import '../../providers.dart';
import '../samples/sample_providers.dart';

// Keys for SharedPreferences
const _jwtKey = 'jwt';
const _emailKey = 'email';

/// Provider for the [AuthRepository].
/// This is where the business logic for authentication lives.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // We pass the ref to the repository so it can read other providers.
  return AuthRepository(ref: ref);
});

/// Provider that exposes the current authentication state (the JWT).
/// UI widgets can listen to this to react to login/logout events.
final authStateProvider = StateProvider<String?>((ref) {
  // On startup, we try to get the JWT from storage.
  // This is a simplified approach. A more robust solution would use a FutureProvider
  // to handle the async nature of reading from SharedPreferences.
  return null;
});

/// Provider that exposes the current user's email.
/// This is populated from SharedPreferences on app start and updated on login.
final userEmailProvider = StateProvider<String?>((ref) => null);

/// Provider to get the full User object for the currently logged-in user.
final currentUserProvider = FutureProvider<User?>((ref) async {
  // By watching authStateProvider, this provider will automatically re-run
  // when the user logs in or out.
  final authState = ref.watch(authStateProvider);
  if (authState == null) {
    return null; // No user logged in, so no current user.
  }

  final userEmail = ref.watch(userEmailProvider);
  if (userEmail == null) {
    return null; // Should not happen if authState is not null, but good practice.
  }

  // allUsersProvider will be re-fetched if it also depends on authState,
  // which is a good pattern to ensure data is not stale.
  final allUsers = await ref.watch(allUsersProvider.future);

  try {
    return allUsers.firstWhere((user) => user.email == userEmail);
  } catch (e) {
    // User not found in the list, or the list was empty.
    return null;
  }
});

/// Provider to handle app initialization.
/// It now loads the entire user session (JWT and email).
final appInitProvider = FutureProvider<void>((ref) async {
  await ref.read(authRepositoryProvider).loadUserSessionFromStorage();
});


class AuthRepository {
  final Ref _ref;

  AuthRepository({required Ref ref}) : _ref = ref;

  Future<SharedPreferences> get _prefs async => await _ref.read(sharedPreferencesProvider.future);

  /// Tries to log in the user and saves the JWT and email if successful.
  Future<void> login(String email, String password) async {
    final uri = Uri.parse('$SERVER_IP/sampletracking_test/login.php');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          "origin": "http://localhost"
        },
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jwt = response.body;
        if (jwt.isNotEmpty) {
          // On success, save both JWT and the email used to log in.
          await _saveJwt(jwt);
          await _saveEmail(email);
          _ref.read(authStateProvider.notifier).state = jwt;
          _ref.read(userEmailProvider.notifier).state = email;
        } else {
           throw ApiException('Login failed: Server returned an empty response.', response.statusCode);
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid credentials.');
      }
      else {
        throw ApiException('Login failed', response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } catch(e) {
      rethrow;
    }
  }

  /// Logs out the user by clearing the JWT and email.
  Future<void> logout() async {
    await _clearJwt();
    await _clearEmail();
    _ref.read(authStateProvider.notifier).state = null;
    _ref.read(userEmailProvider.notifier).state = null;
  }

  /// Loads the JWT and Email from storage on app startup.
  Future<void> loadUserSessionFromStorage() async {
    final jwt = await _getJwt();
    final email = await _getEmail();
    _ref.read(authStateProvider.notifier).state = jwt;
    _ref.read(userEmailProvider.notifier).state = email;
  }

  // --- JWT Helpers ---
  Future<void> _saveJwt(String jwt) async {
    final prefs = await _prefs;
    await prefs.setString(_jwtKey, jwt);
  }

  Future<void> _clearJwt() async {
    final prefs = await _prefs;
    await prefs.remove(_jwtKey);
  }

  Future<String?> _getJwt() async {
    final prefs = await _prefs;
    return prefs.getString(_jwtKey);
  }

  // --- Email Helpers ---
  Future<void> _saveEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(_emailKey, email);
  }

  Future<void> _clearEmail() async {
    final prefs = await _prefs;
    await prefs.remove(_emailKey);
  }

  Future<String?> _getEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_emailKey);
  }
}