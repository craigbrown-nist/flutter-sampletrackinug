import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Define the state class
class CellsPageState {
  final bool showFull;
  final String cellTypeFilter;

  // From the old code, this seems to be the list of possible filters.
  static const List<String> cellTypes = [
    "Van A", "Van B", "Van C", "Van D", "Van E", "Al 1.2cc", "Al 1.6cc",
    "Al 3.1cc", "Al 6.3cc", "DCS Al", "Single Crystal", "Brookhaven", "Other",
  ];

  CellsPageState({
    this.showFull = true,
    this.cellTypeFilter = "Van A",
  });

  CellsPageState copyWith({
    bool? showFull,
    String? cellTypeFilter,
  }) {
    return CellsPageState(
      showFull: showFull ?? this.showFull,
      cellTypeFilter: cellTypeFilter ?? this.cellTypeFilter,
    );
  }
}

// 2. Create the StateNotifier
class CellsPageController extends StateNotifier<CellsPageState> {
  CellsPageController() : super(CellsPageState());

  void setShowFull(bool isFull) {
    state = state.copyWith(showFull: isFull);
  }

  void setCellTypeFilter(String filter) {
    state = state.copyWith(cellTypeFilter: filter);
  }
}

// 3. Create the provider
final cellsPageControllerProvider =
    StateNotifierProvider<CellsPageController, CellsPageState>((ref) {
  return CellsPageController();
});
