import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'API.dart';

// --- Core Service Providers ---

/// Provider for the [ApiClient].
///
/// This will be used by other providers and repositories to make API calls.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider for [SharedPreferences].
///
/// This is overridden in main.dart to provide the actual instance.
/// We use a FutureProvider here because obtaining the SharedPreferences instance is async.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});
