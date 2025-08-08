import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../API.dart';
import '../../providers.dart';

const _jwtKey = 'jwt';

/// Provider for the [AuthRepository].
/// This is where the business logic for authentication lives.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  // We can't watch a FutureProvider directly in a regular Provider,
  // so we will pass the ref to the repository to read it when needed.
  return AuthRepository(apiClient: apiClient, ref: ref);
});

import 'dart:convert';
import '../../models/User.dart';
import '../samples/sample_providers.dart';

/// Provider that exposes the current authentication state (the JWT).
/// UI widgets can listen to this to react to login/logout events.
final authStateProvider = StateProvider<String?>((ref) {
  // On startup, we try to get the JWT from storage.
  // This is a simplified approach. A more robust solution would use a FutureProvider
  // to handle the async nature of reading from SharedPreferences.
  return null;
});

/// Decodes the JWT to get the user's email.
/// NOTE: This is a simplified manual JWT decoder. For production, a robust
/// library like `jwt_decode` should be used.
final userEmailProvider = Provider<String?>((ref) {
  final jwt = ref.watch(authStateProvider);
  if (jwt == null) return null;

  final parts = jwt.split('.');
  if (parts.length != 3) return null;

  try {
    final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    return payload['email'];
  } catch (e) {
    return null;
  }
});

/// Provider to get the full User object for the currently logged-in user.
final currentUserProvider = FutureProvider<User?>((ref) async {
  final userEmail = ref.watch(userEmailProvider);
  final allUsers = await ref.watch(allUsersProvider.future);

  if (userEmail == null) return null;

  try {
    return allUsers.firstWhere((user) => user.email == userEmail);
  } catch (e) {
    // User not found in the list
    return null;
  }
});


class AuthRepository {
  final ApiClient _apiClient;
  final Ref _ref;

  AuthRepository({required ApiClient apiClient, required Ref ref})
      : _apiClient = apiClient,
        _ref = ref;

  Future<SharedPreferences> get _prefs async => await _ref.read(sharedPreferencesProvider.future);

  /// Tries to log in the user and saves the JWT if successful.
  Future<void> login(String email, String password) async {
    try {
      final jwt = await _apiClient.attemptLogIn(email, password);
      await _saveJwt(jwt);
      _ref.read(authStateProvider.notifier).state = jwt;
    } catch (e) {
      // The API client will throw a specific exception on failure.
      // The UI layer can catch this and display an appropriate error.
      rethrow;
    }
  }

  /// Logs out the user by clearing the JWT.
  Future<void> logout() async {
    await _clearJwt();
    _ref.read(authStateProvider.notifier).state = null;
  }

  /// Loads the JWT from storage on app startup.
  Future<void> loadJwtFromStorage() async {
    final jwt = await _getJwt();
    _ref.read(authStateProvider.notifier).state = jwt;
  }

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
}
