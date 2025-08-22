import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/Sample.dart';
import 'sample_providers.dart';

enum SortType { id, chemical }

// 1. Define the state class
class AllPageState {
  final String searchQuery;
  final bool isSelectionMode;
  final Set<String> selectedSampleIds;
  final SortType sortType;

  AllPageState({
    this.searchQuery = '',
    this.isSelectionMode = false,
    this.selectedSampleIds = const {},
    this.sortType = SortType.id,
  });

  AllPageState copyWith({
    String? searchQuery,
    bool? isSelectionMode,
    Set<String>? selectedSampleIds,
    SortType? sortType,
  }) {
    return AllPageState(
      searchQuery: searchQuery ?? this.searchQuery,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedSampleIds: selectedSampleIds ?? this.selectedSampleIds,
      sortType: sortType ?? this.sortType,
    );
  }
}

// 2. Create the StateNotifier
class AllPageController extends StateNotifier<AllPageState> {
  AllPageController() : super(AllPageState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSort(SortType sortType) {
    state = state.copyWith(sortType: sortType);
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
  final pageState = ref.watch(allPageControllerProvider);
  final searchQuery = pageState.searchQuery;
  final sortType = pageState.sortType;

  return samplesAsyncValue.when(
    data: (samples) {
      // Filter logic
      final filtered = searchQuery.isEmpty
          ? samples
          : samples.where((sample) {
              final query = searchQuery.toLowerCase();
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

      // Sorting logic
      filtered.sort((a, b) {
        switch (sortType) {
          case SortType.id:
            // Handle nulls and parse errors gracefully for numeric sort
            final idA = int.tryParse(a.sampleId ?? '0') ?? 0;
            final idB = int.tryParse(b.sampleId ?? '0') ?? 0;
            return idB.compareTo(idA); // Descending
          case SortType.chemical:
            return (a.chemical ?? '').compareTo(b.chemical ?? ''); // Ascending
        }
      });

      return filtered;
    },
    loading: () => [],
    error: (e, st) => [],
  );
});
