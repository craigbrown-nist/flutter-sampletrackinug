import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_samples/providers.dart';

 import '../../models/Cells.dart';
import '../../models/Forms.dart';
import '../../models/Hazards.dart';
import '../../models/Sample.dart' hide Hazards;
import '../../models/Units.dart';
import '../../models/User.dart';
import '../auth/auth_repository.dart';

// --- Data Fetching Providers ---

final userSamplesProvider = FutureProvider<List<Sample>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  final userEmail = ref.watch(userEmailProvider);

  // If the user is not logged in (no JWT or no email), return an empty list.
  // The UI will rebuild automatically when the auth state changes.
  if (jwt == null || userEmail == null) {
    return [];
  }

  return apiClient.getUserSamples(jwt, userEmail: userEmail);
});

final allSamplesProvider = FutureProvider<List<Sample>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  if (jwt == null) return [];
  return apiClient.getSamples(jwt);
});

final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  if (jwt == null) return [];
  return apiClient.getUsers(jwt);
});

final samplesToEmptyProvider = FutureProvider<List<Sample>>((ref) async {
  // This provider depends on the result of allSamplesProvider
  final allSamples = await ref.watch(allSamplesProvider.future);
  return allSamples.where((s) => s.locationid == "Ready to Unload").toList();
});

final formsProvider = FutureProvider<List<FormsOfSample>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  if (jwt == null) return [];
  return apiClient.getForms(jwt);
});

final unitsProvider = FutureProvider<List<UnitsOfSample>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  if (jwt == null) return [];
  return apiClient.getUnits(jwt);
});

final hazardsProvider = FutureProvider<List<Hazards>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  if (jwt == null) return [];
  return apiClient.getHazards(jwt);
});

final fullCellsProvider = FutureProvider<List<Cells>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  if (jwt == null) return [];
  return apiClient.getCans(jwt, status: 'full');
});

final emptyCellsProvider = FutureProvider<List<Cells>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  if (jwt == null) return [];
  return apiClient.getCans(jwt, status: 'empty');
});