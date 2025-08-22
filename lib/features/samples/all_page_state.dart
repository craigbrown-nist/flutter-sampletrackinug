import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/Sample.dart';
import 'sample_providers.dart';

enum SortType { id, chemical }
enum SortDirection { asc, desc }

// 1. Define the state class
class AllPageState {
  final String searchQuery;
  final bool isSelectionMode;
  final Set<String> selectedSampleIds;
  final SortType sortType;
  final SortDirection sortDirection;

  AllPageState({
    this.searchQuery = '',
    this.isSelectionMode = false,
    this.selectedSampleIds = const {},
    this.sortType = SortType.id,
    this.sortDirection = SortDirection.desc,
  });

  AllPageState copyWith({
    String? searchQuery,
    bool? isSelectionMode,
    Set<String>? selectedSampleIds,
    SortType? sortType,
    SortDirection? sortDirection,
  }) {
    return AllPageState(
      searchQuery: searchQuery ?? this.searchQuery,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedSampleIds: selectedSampleIds ?? this.selectedSampleIds,
      sortType: sortType ?? this.sortType,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

// 2. Create the StateNotifier
class AllPageController extends StateNotifier<AllPageState> {
  AllPageController() : super(AllPageState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSort(SortType newSortType) {
    if (state.sortType == newSortType) {
      // If same type, toggle direction
      final newDirection = state.sortDirection == SortDirection.asc ? SortDirection.desc : SortDirection.asc;
      state = state.copyWith(sortDirection: newDirection);
    } else {
      // If new type, set it and default to descending
      state = state.copyWith(sortType: newSortType, sortDirection: SortDirection.desc);
    }
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
        int comparison;
        if (pageState.sortType == SortType.id) {
          comparison = (int.tryParse(a.sampleId ?? '0') ?? 0)
              .compareTo(int.tryParse(b.sampleId ?? '0') ?? 0);
        } else {
          comparison = (a.chemical ?? '').toLowerCase().compareTo((b.chemical ?? '').toLowerCase());
        }
        return pageState.sortDirection == SortDirection.asc ? comparison : -comparison;
      });

      return filtered;
    },
    loading: () => [],
    error: (e, st) => [],
  );
});
