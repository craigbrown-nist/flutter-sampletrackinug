import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_samples/features/cells/cell_providers.dart';
import 'package:flutter_samples/features/cells/cells_page_state.dart';
import 'package:flutter_samples/models/Cells.dart';

import 'CellDetailPage.dart';

class CellsPage extends ConsumerWidget {
  const CellsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredCells = ref.watch(filteredCellsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cells'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Invalidate providers to force a refetch
              ref.invalidate(fullCellsProvider);
              ref.invalidate(emptyCellsProvider);
            },
          ),
        ],
      ),
      body: filteredCells.when(
        data: (cells) => _buildCellList(context, cells),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterSheet(context, ref),
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildCellList(BuildContext context, List<Cells> cells) {
    if (cells.isEmpty) {
      return const Center(child: Text('No cells match the current filter.'));
    }
    return ListView.builder(
      itemCount: cells.length,
      itemBuilder: (context, index) {
        final cell = cells[index];
        return ListTile(
          leading: Text(cell.barcode.toString()),
          title: Text(cell.description.toString()),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CellDetailPage(cell: cell),
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final pageState = ref.read(cellsPageControllerProvider);
    final pageController = ref.read(cellsPageControllerProvider.notifier);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder for local state in the sheet
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Show Full Cells'),
                    value: pageState.showFull,
                    onChanged: (value) {
                      pageController.setShowFull(value);
                      // No need to call Navigator.pop, the UI will update automatically
                    },
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Cell Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: CellsPageState.cellTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: pageState.cellTypeFilter == type,
                        onSelected: (isSelected) {
                          if (isSelected) {
                            pageController.setCellTypeFilter(type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                   const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement Create New Cell Dialog
                      },
                      child: const Text('Create a New Sample Cell/Can'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
