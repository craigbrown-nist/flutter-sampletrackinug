import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/Cells.dart';
import '../samples/sample_providers.dart';
import 'cells_page_state.dart';

// A map to associate the filter string with the description from the data model.
// This is more robust than a giant if/else chain.
const Map<String, String> cellFilterMap = {
  "Van A": "Vanadium A",
  "Van B": "Vanadium B",
  "Van C": "Vanadium C",
  "Van D": "Vanadium D",
  "Van E": "Vanadium E",
  "Al 1.2cc": "Al 1.2cc",
  "Al 1.6cc": "Al 1.6cc",
  "Al 3.1cc": "Al 3.1cc",
  "Al 6.3cc": "Al 6.3cc",
  "DCS Al": "DCS Al",
  "Single Crystal": "Single Crystal Small", // Or Large, the old code was ambiguous
  "Brookhaven": "Brookhaven SC",
  "Other": "a generic cell",
};


final filteredCellsProvider = Provider<AsyncValue<List<Cells>>>((ref) {
  final pageState = ref.watch(cellsPageControllerProvider);
  final fullCells = ref.watch(fullCellsProvider);
  final emptyCells = ref.watch(emptyCellsProvider);

  final sourceAsyncValue = pageState.showFull ? fullCells : emptyCells;

  return sourceAsyncValue.when(
    data: (cells) {
      final targetDescription = cellFilterMap[pageState.cellTypeFilter];

      final filtered = cells.where((cell) {
        // The old code was ambiguous about how 'Single Crystal' and 'Other' were mapped.
        // This is a reasonable interpretation.
        if (pageState.cellTypeFilter == "Single Crystal") {
          return cell.description == "Single Crystal Small" || cell.description == "Single Crystal Large";
        }
        if (pageState.cellTypeFilter == "Other") {
          // If it doesn't match any known type, it's 'Other'
          return !cellFilterMap.containsValue(cell.description);
        }
        return cell.description == targetDescription;
      }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
