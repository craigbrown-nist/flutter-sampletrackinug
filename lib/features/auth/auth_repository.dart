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
/// This is where the business logic for authentication lives.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // We pass the ref to the repository so it can read other providers.
  return AuthRepository(ref: ref);
});

/// Provider that exposes the current authentication state (the JWT).
/// UI widgets can listen to this to react to login/logout events.
final authStateProvider = StateProvider<String?>((ref) {
  // On startup, we try to get the JWT from storage.
  return null;
});

/// Decodes the JWT and provides the payload as a map.
/// This is the new single source of truth for user information like email.
final decodedJwtProvider = Provider<Map<String, dynamic>?>((ref) {
  final jwt = ref.watch(authStateProvider);
  if (jwt != null) {
    try {
      return JwtDecoder.decode(jwt);
    } catch (e) {
      // If decoding fails, the token is invalid. Return null.
      return null;
    }
  }
  return null;
});

/// A provider that returns `true` if the current JWT is present, not expired,
/// and ready to be used (i.e., the 'not before' time has passed).
final isJwtValidProvider = Provider<bool>((ref) {
  final decodedToken = ref.watch(decodedJwtProvider);
  if (decodedToken == null) {
    return false;
  }

  final now = DateTime.now();

  // Check expiration time
  if (decodedToken.containsKey('exp')) {
    final exp = DateTime.fromMillisecondsSinceEpoch((decodedToken['exp'] as int) * 1000);
    if (exp.isBefore(now)) {
      return false; // Token is expired
    }
  }

  // Check 'not before' time
  if (decodedToken.containsKey('nbf')) {
    final nbf = DateTime.fromMillisecondsSinceEpoch((decodedToken['nbf'] as int) * 1000);
    if (nbf.isAfter(now)) {
      return false; // Token is not yet valid
    }
  }

  return true; // Token is valid
});


/// Provider to get the full User object for the currently logged-in user.
/// It now depends on the token being valid before proceeding.
final currentUserProvider = FutureProvider<User?>((ref) async {
  final isTokenValid = ref.watch(isJwtValidProvider);
  if (!isTokenValid) return null;

  // We can safely read the decoded JWT now, as we know it's valid.
  final decodedJwt = ref.read(decodedJwtProvider)!;
  final allUsers = await ref.watch(allUsersProvider.future);

  if (!decodedJwt.containsKey('email')) {
    return null;
  }
  final userEmail = decodedJwt['email'] as String;

  try {
    return allUsers.firstWhere((user) => user.email == userEmail);
  } catch (e) {
    // User not found in the list
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
          // On success, save the JWT. The email is derived from the JWT itself.
          await _saveJwt(jwt);
          _ref.read(authStateProvider.notifier).state = jwt;
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