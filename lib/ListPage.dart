import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'UI/DetailPage.dart';
import 'UI/NewPage.dart';
import 'UI/adminNavDrawer.dart';
import 'API.dart';
import 'UI/Toast.dart';
import 'features/samples/list_page_state.dart';
import 'features/samples/sample_providers.dart';
import 'models/Sample.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered provider to get the async state of the filtered list.
    final filteredSamplesAsync = ref.watch(filteredSamplesProvider);
    // We still need pageState and pageController for other parts of the UI.
    final pageState = ref.watch(listPageControllerProvider);
    final pageController = ref.read(listPageControllerProvider.notifier);

    return Scaffold(
      // For simplicity, using the old drawer. This would also be refactored.
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context, ref),
      // Use the new async provider to build the body.
      body: filteredSamplesAsync.when(
        data: (samples) => _buildSampleList(samples, pageState, pageController),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      ),
      bottomNavigationBar: _buildBottomAppBar(ref),
      floatingActionButton: pageState.isSelectionMode
          ? _buildSpeedDial(context, ref)
          : _buildAddButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(listPageControllerProvider);
    final pageController = ref.read(listPageControllerProvider.notifier);
    final searchController = TextEditingController(text: pageState.searchQuery);
    // Move cursor to the end
    searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));


    return AppBar(
      title: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          hintStyle:  TextStyle(color: Colors.grey),
        ),
        onChanged: (value) {
          pageController.setSearchQuery(value);
        },
      ),
      actions: [
        if (pageState.searchQuery.isNotEmpty || pageState.isSelectionMode)
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              pageController.setSearchQuery('');
              if (pageState.isSelectionMode) {
                pageController.toggleSelectionMode();
              }
            },
          ),
        IconButton(
          icon:  Icon(MdiIcons.qrcodeScan, color: Colors.blue),
          onPressed: () {
            // TODO: Implement barcode scanning logic
          },
        ),
      ],
    );
  }

  Widget _buildSampleList(List<Sample> samples, ListPageState pageState, ListPageController pageController) {
    if (samples.isEmpty) {
      return const Center(child: Text('No samples found.'));
    }

    return ListView.builder(
      itemCount: samples.length,
      itemBuilder: (context, index) {
        final sample = samples[index];
        final isSelected = pageState.selectedSampleIds.contains(sample.sampleId);
        final hasHazard = sample.hazards?.isNotEmpty ?? false;
        final textColor = hasHazard ? Colors.red : null;

        return InkWell(
          onTap: () {
            if (pageState.isSelectionMode) {
              pageController.toggleSampleSelection(sample.sampleId!);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(sample: sample),
                ),
              );
            }
          },
          onLongPress: () {
            if (!pageState.isSelectionMode) {
              pageController.toggleSelectionMode();
              pageController.toggleSampleSelection(sample.sampleId!);
            }
          },
          child: Container(
            color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
            child: ListTile(
              leading: Text(
                sample.sampleId ?? 'N/A',
                style: TextStyle(color: textColor),
              ),
              title: Text(
                sample.chemical ?? 'Unknown Chemical',
                style: TextStyle(color: textColor),
              ),
              trailing: pageState.isSelectionMode
                  ? Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank)
                  : const Icon(Icons.keyboard_arrow_right),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAppBar(WidgetRef ref) {
    final pageController = ref.read(listPageControllerProvider.notifier);
    final pageState = ref.watch(listPageControllerProvider);

    return BottomAppBar(
      color: const Color.fromRGBO(158, 166, 186, 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(
              MdiIcons.orderNumericDescending,
              color: pageState.sortType == SortType.id ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              pageController.setSort(SortType.id);
            },
          ),
          IconButton(
            icon: Icon(
              MdiIcons.orderAlphabeticalDescending,
              color: pageState.sortType == SortType.chemical ? Colors.amber : Colors.white,
            ),
            onPressed: () {
              pageController.setSort(SortType.chemical);
            },
          ),
          IconButton(
            icon:  Icon(MdiIcons.recycle, color: Colors.white),
            onPressed: () {
              ref.invalidate(userSamplesProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const NewPage()),
      ),
    );
  }

  SpeedDial _buildSpeedDial(BuildContext context, WidgetRef ref) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.battery_full, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () {
            // TODO: Implement 'Empty cells' logic
          },
          label: 'Empty cells',
        ),
        SpeedDialChild(
          child: const Icon(Icons.train, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            // TODO: Implement 'Move' logic
          },
          label: 'Move',
        ),
        SpeedDialChild(
          child: const Icon(Icons.remove_red_eye, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () async {
            final pageController = ref.read(listPageControllerProvider.notifier);
            final pageState = ref.read(listPageControllerProvider);
            final selectedIds = pageState.selectedSampleIds;
            final allSamples = ref.read(userSamplesProvider).value;
            final apiClient = ref.read(apiClientProvider);
            final jwt = ref.read(authStateProvider);

            if (selectedIds.isEmpty || allSamples == null || jwt == null) {
              toast(context, "No samples selected or error loading data.", Colors.orange);
              return;
            }

            final samplesToArchive = allSamples.where((s) => selectedIds.contains(s.sampleId)).toList();

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );

            try {
              final List<Future> archiveFutures = [];
              for (final sample in samplesToArchive) {
                final updatedSample = sample.copyWith(archived: '1');
                archiveFutures.add(apiClient.updateSample(jwt, sample: updatedSample));
              }

              await Future.wait(archiveFutures);

              Navigator.of(context).pop(); // Dismiss loading dialog
              toast(context, "${samplesToArchive.length} sample(s) archived.", Colors.green);

              ref.invalidate(userSamplesProvider);
              pageController.clearSelection();
              pageController.toggleSelectionMode();

            } catch (e) {
              Navigator.of(context).pop(); // Dismiss loading dialog
              toast(context, "Error archiving samples: $e", Colors.red);
            }
          },
          label: 'Archive',
        ),
      ],
    );
  }
}
