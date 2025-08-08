import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../API.dart';
import '../../models/Cells.dart';
import '../../models/Forms.dart';
import '../../models/Hazards.dart';
import '../../models/Sample.dart' hide Hazards;
import '../../models/Units.dart';
import '../../models/User.dart';
import '../auth/auth_repository.dart';

// This provider is a bit of a hack to get the JWT.
// In a real app, you'd have a more robust way of handling this,
// perhaps by having the authStateProvider return the whole User object.
final _jwtProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState == null) {
    throw UnimplementedError('JWT is null, user must be logged in to access this provider.');
  }
  return authState;
});

// --- Data Fetching Providers ---

final userSamplesProvider = FutureProvider<List<Sample>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(_jwtProvider);
  // This is a simplification. In a real app, you wouldn't hardcode the user email.
  // You would likely get it from the decoded JWT or another state provider.
  // For now, we don't have the user's email readily available in a provider.
  // This part of the logic will need to be completed when the user model is integrated
  // into the auth state.
  // final userEmail = ref.watch(userProvider).value?.email ?? '';
  // For now, this will fail until we refactor the auth state.
  // This highlights the difficulty of piecemeal refactoring.
  // Let's assume for now we can get the user email from somewhere.
  // This part of the code is NOT yet functional.
  // TODO: Get user email from a proper provider.
  const userEmail = "test@test.com"; // Placeholder
  return apiClient.getUserSamples(jwt, userEmail: userEmail);
});

final allSamplesProvider = FutureProvider<List<Sample>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(_jwtProvider);
  return apiClient.getSamples(jwt);
});

final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(_jwtProvider);
  return apiClient.getUsers(jwt);
});

final formsProvider = FutureProvider<List<FormsOfSample>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(_jwtProvider);
  return apiClient.getForms(jwt);
});

final unitsProvider = FutureProvider<List<UnitsOfSample>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(_jwtProvider);
  return apiClient.getUnits(jwt);
});

final hazardsProvider = FutureProvider<List<Hazards>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(_jwtProvider);
  return apiClient.getHazards(jwt);
});

final fullCellsProvider = FutureProvider<List<Cells>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(_jwtProvider);
  return apiClient.getCans(jwt, status: 'full');
});

final emptyCellsProvider = FutureProvider<List<Cells>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(_jwtProvider);
  return apiClient.getCans(jwt, status: 'empty');
});
