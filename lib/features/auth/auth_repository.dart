import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../API.dart';
import '../../Functions/Server.dart';
import '../../models/User.dart';
import '../../providers.dart';
import '../samples/sample_providers.dart';

// Key for SharedPreferences
const _jwtKey = 'jwt';

/// Provider for the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref: ref);
});

/// Provider that exposes the current authentication state (the JWT string).
final authStateProvider = StateProvider<String?>((ref) => null);

/// Provider that decodes the JWT and exposes its payload as a map.
/// Returns null if the token is null, invalid, or expired.
final decodedJwtProvider = Provider<Map<String, dynamic>?>((ref) {
  final jwt = ref.watch(authStateProvider);
  if (jwt == null) return null;
  try {
    if (JwtDecoder.isExpired(jwt)) {
      // Handle expired token, maybe by triggering a logout
      return null;
    }
    return JwtDecoder.decode(jwt);
  } catch (e) {
    // Handle error decoding token
    return null;
  }
});

/// Provider to get the full User object for the currently logged-in user.
final currentUserProvider = FutureProvider<User?>((ref) async {
  final decodedJwt = ref.watch(decodedJwtProvider);
  if (decodedJwt == null) {
    return null; // No user logged in or token is invalid/expired.
  }

  final userEmail = decodedJwt['email'] as String?;
  if (userEmail == null) {
    return null; // Email claim missing from token.
  }

  // This will re-fetch all users when the auth state changes, which is correct.
  final allUsers = await ref.watch(allUsersProvider.future);

  try {
    return allUsers.firstWhere((user) => user.email == userEmail);
  } catch (e) {
    // User from token not found in the user list.
    return null;
  }
});

/// Provider to handle app initialization.
final appInitProvider = FutureProvider<void>((ref) async {
  await ref.read(authRepositoryProvider).loadUserSessionFromStorage();
});


class AuthRepository {
  final Ref _ref;

  AuthRepository({required Ref ref}) : _ref = ref;

  Future<SharedPreferences> get _prefs async => await _ref.read(sharedPreferencesProvider.future);

  /// Tries to log in the user and saves the JWT if successful.
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
        String jwt;
        try {
          jwt = json.decode(response.body);
        } on FormatException {
          jwt = response.body;
        }

        if (jwt.isNotEmpty) {
          await _saveJwt(jwt);
          _ref.read(authStateProvider.notifier).state = jwt;
        } else {
          throw ApiException('Login failed: Server returned an empty response.', response.statusCode);
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid credentials.');
      } else {
        throw ApiException('Login failed', response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } catch(e) {
      rethrow;
    }
  }

  /// Logs out the user by clearing the JWT.
  Future<void> logout() async {
    await _clearJwt();
    _ref.read(authStateProvider.notifier).state = null;
  }

  /// Loads the JWT from storage on app startup.
  Future<void> loadUserSessionFromStorage() async {
    final jwt = await _getJwt();
    _ref.read(authStateProvider.notifier).state = jwt;
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
}