import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/Sample.dart';
import 'sample_providers.dart';

// 1. Define the state class
class AllPageState {
  final String searchQuery;
  final bool isSelectionMode;
  final Set<String> selectedSampleIds;

  AllPageState({
    this.searchQuery = '',
    this.isSelectionMode = false,
    this.selectedSampleIds = const {},
  });

  AllPageState copyWith({
    String? searchQuery,
    bool? isSelectionMode,
    Set<String>? selectedSampleIds,
  }) {
    return AllPageState(
      searchQuery: searchQuery ?? this.searchQuery,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedSampleIds: selectedSampleIds ?? this.selectedSampleIds,
    );
  }
}

// 2. Create the StateNotifier
class AllPageController extends StateNotifier<AllPageState> {
  AllPageController() : super(AllPageState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedSampleIds: state.isSelectionMode ? {} : state.selectedSampleIds,
    );
  }

  void toggleSampleSelection(String sampleId) {
    if (!state.isSelectionMode) return;

    final newSet = Set<String>.from(state.selectedSampleIds);
    if (newSet.contains(sampleId)) {
      newSet.remove(sampleId);
    } else {
      newSet.add(sampleId);
    }
    state = state.copyWith(selectedSampleIds: newSet);
  }

  void clearSelection() {
    state = state.copyWith(selectedSampleIds: {});
  }
}

// 3. Create the provider
final allPageControllerProvider =
    StateNotifierProvider<AllPageController, AllPageState>((ref) {
  return AllPageController();
});

// 4. Create computed provider for filtered list
final filteredAllSamplesProvider = Provider<List<Sample>>((ref) {
  final samplesAsyncValue = ref.watch(allSamplesProvider);
  final searchQuery = ref.watch(allPageControllerProvider).searchQuery;

  return samplesAsyncValue.when(
    data: (samples) {
      if (searchQuery.isEmpty) {
        return samples;
      }
      return samples.where((sample) {
        final query = searchQuery.toLowerCase();
        // This search is more comprehensive as per the original AllPage
        return (sample.sampleId?.toLowerCase().contains(query) ?? false) ||
               (sample.sampleName?.toLowerCase().contains(query) ?? false) ||
               (sample.chemical?.toLowerCase().contains(query) ?? false) ||
               (sample.cellbarcode?.toLowerCase().contains(query) ?? false) ||
               (sample.sampenvbarcode?.toLowerCase().contains(query) ?? false) ||
               (sample.externalUser?.toLowerCase().contains(query) ?? false) ||
               (sample.locationString?.toLowerCase().contains(query) ?? false) ||
               (sample.owner?.toLowerCase().contains(query) ?? false) ||
               (sample.userName?.toLowerCase().contains(query) ?? false) ||
               (sample.extraNotes?.toLowerCase().contains(query) ?? false);
      }).toList();
    },
    loading: () => [],
    error: (e, st) => [],
  );
});
