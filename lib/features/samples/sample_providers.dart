import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_samples/providers.dart';

 import '../../models/Cells.dart';
import '../../models/Forms.dart';
import '../../models/Hazards.dart';
import '../../models/Sample.dart' hide Hazards;
import '../../models/Units.dart';
import '../auth/auth_repository.dart';

// --- Data Fetching Providers ---

final userSamplesProvider = FutureProvider<List<Sample>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  final decodedJwt = ref.watch(decodedJwtProvider);
  final userEmail = decodedJwt?['email'] as String?;

  // If the user is not logged in (no valid token or no email in token), return an empty list.
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