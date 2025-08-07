import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'UI/DetailPage.dart';
import 'UI/NewPage.dart';
import 'UI/adminNavDrawer.dart';
import 'features/samples/list_page_state.dart';
import 'features/samples/sample_providers.dart';
import 'models/Sample.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samplesAsyncValue = ref.watch(userSamplesProvider);
    final filteredSamples = ref.watch(filteredSamplesProvider);
    final pageState = ref.watch(listPageControllerProvider);
    final pageController = ref.read(listPageControllerProvider.notifier);

    return Scaffold(
      // For simplicity, using the old drawer. This would also be refactored.
      drawer: adminNavDrawer(context),
      appBar: _buildAppBar(context, ref),
      body: samplesAsyncValue.when(
        data: (_) => _buildSampleList(filteredSamples, pageState, pageController),
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
        decoration: InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.grey),
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
          icon: const Icon(MdiIcons.qrcodeScan, color: Colors.blue),
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
              leading: Text(sample.sampleId ?? 'N/A'),
              title: Text(sample.chemical ?? 'Unknown Chemical'),
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
    return BottomAppBar(
      color: const Color.fromRGBO(158, 166, 186, 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: const Icon(MdiIcons.orderNumericDescending, color: Colors.white),
            onPressed: () {
              // TODO: Implement sorting logic
            },
          ),
          IconButton(
            icon: const Icon(MdiIcons.orderAlphabeticalDescending, color: Colors.white),
            onPressed: () {
              // TODO: Implement sorting logic
            },
          ),
          IconButton(
            icon: const Icon(MdiIcons.recycle, color: Colors.white),
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
          onTap: () {
            // TODO: Implement 'Archive' logic
          },
          label: 'Archive',
        ),
      ],
    );
  }
}
