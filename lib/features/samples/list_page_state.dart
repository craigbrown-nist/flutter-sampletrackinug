import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/Sample.dart';

// 1. Define the state class
class ListPageState {
  final String searchQuery;
  final bool isSelectionMode;
  final Set<String> selectedSampleIds;

  ListPageState({
    this.searchQuery = '',
    this.isSelectionMode = false,
    this.selectedSampleIds = const {},
  });

  ListPageState copyWith({
    String? searchQuery,
    bool? isSelectionMode,
    Set<String>? selectedSampleIds,
  }) {
    return ListPageState(
      searchQuery: searchQuery ?? this.searchQuery,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedSampleIds: selectedSampleIds ?? this.selectedSampleIds,
    );
  }
}

// 2. Create the StateNotifier
class ListPageController extends StateNotifier<ListPageState> {
  ListPageController() : super(ListPageState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      // Clear selections when exiting selection mode
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
final listPageControllerProvider =
    StateNotifierProvider<ListPageController, ListPageState>((ref) {
  return ListPageController();
});

// 4. (Optional) Create computed providers (selectors) for convenience
final filteredSamplesProvider = Provider<List<Sample>>((ref) {
  final samplesAsyncValue = ref.watch(userSamplesProvider);
  final searchQuery = ref.watch(listPageControllerProvider).searchQuery;

  return samplesAsyncValue.when(
    data: (samples) {
      if (searchQuery.isEmpty) {
        return samples;
      }
      return samples.where((sample) {
        final query = searchQuery.toLowerCase();
        return (sample.sampleId?.toLowerCase().contains(query) ?? false) ||
               (sample.sampleName?.toLowerCase().contains(query) ?? false) ||
               (sample.chemical?.toLowerCase().contains(query) ?? false) ||
               (sample.cellbarcode?.toLowerCase().contains(query) ?? false) ||
               (sample.sampenvbarcode?.toLowerCase().contains(query) ?? false);
      }).toList();
    },
    loading: () => [],
    error: (e, st) => [],
  );
});
