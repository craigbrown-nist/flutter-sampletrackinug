import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../features/samples/all_page_state.dart';
import '../features/samples/sample_providers.dart';
import '../features/auth/auth_repository.dart';
import '../models/Sample.dart';
import '../providers.dart';
import 'API.dart';
import 'DetailPage.dart';
import 'MoveDialogContent.dart';
import 'NewPage.dart';
import 'Toast.dart';
import 'adminNavDrawer.dart';

class AllPage extends ConsumerWidget {
  const AllPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samplesAsyncValue = ref.watch(allSamplesProvider);
    final filteredSamples = ref.watch(filteredAllSamplesProvider);
    final pageState = ref.watch(allPageControllerProvider);
    final pageController = ref.read(allPageControllerProvider.notifier);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context, ref),
      body: samplesAsyncValue.when(
        data: (_) => _buildSampleList(filteredSamples, pageState, pageController),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      ),
      bottomNavigationBar: _buildBottomAppBar(ref),
      floatingActionButton: _buildSpeedDial(context, ref),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(allPageControllerProvider);
    final pageController = ref.read(allPageControllerProvider.notifier);
    final searchController = TextEditingController(text: pageState.searchQuery);
    searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));

    return AppBar(
      title: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: 'Search all samples...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
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
          icon:   Icon(MdiIcons.qrcodeScan, color: Colors.blue),
          onPressed: () {
            // TODO: Implement barcode scanning logic
          },
        ),
      ],
    );
  }

  Widget _buildSampleList(List<Sample> samples, AllPageState pageState, AllPageController pageController) {
    if (samples.isEmpty) {
      return const Center(child: Text('No samples found.'));
    }

    return ListView.builder(
      itemCount: samples.length,
      itemBuilder: (context, index) {
        final sample = samples[index];
        final isSelected = pageState.selectedSampleIds.contains(sample.sampleId);
        final isArchived = sample.archived == '1';
        final hasHazard = sample.haz1 != null || sample.haz2 != null || sample.haz3 != null || sample.haz4 != null;

        Color? textColor;
        if (hasHazard && isArchived) {
          textColor = Colors.pink;
        } else if (hasHazard) {
          textColor = Colors.red;
        } else if (isArchived) {
          textColor = Colors.grey;
        }

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
              subtitle: Text(
                sample.userName ?? 'Unknown User',
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
    final pageController = ref.read(allPageControllerProvider.notifier);
    final pageState = ref.watch(allPageControllerProvider);

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
            icon:   Icon(MdiIcons.recycle, color: Colors.white),
            onPressed: () {
              ref.invalidate(allSamplesProvider);
            },
          ),
        ],
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
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => const NewPage()),
          ),
          label: 'Add',
        ),
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
          onTap: () async {
            final pageController = ref.read(allPageControllerProvider.notifier);
            final pageState = ref.read(allPageControllerProvider);
            final selectedIds = pageState.selectedSampleIds;
            final allSamples = ref.read(allSamplesProvider).value;
            final apiClient = ref.read(apiClientProvider);
            final jwt = ref.read(authStateProvider);

            if (selectedIds.isEmpty || allSamples == null || jwt == null) {
              toast(context, "No samples selected or error loading data.", Colors.orange);
              return;
            }

            final samplesToMove = allSamples.where((s) => selectedIds.contains(s.sampleId)).toList();

            final newLocation = await showDialog<Map<String, String?>>(
              context: context,
              builder: (context) => MoveDialogContent(initialSample: samplesToMove.first),
            );

            if (newLocation == null) return;

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );

            try {
              final List<Future> moveFutures = [];
              final locationString = "${newLocation['place'] ?? ''}/${newLocation['location'] ?? ''}/${newLocation['locationid'] ?? ''}/${newLocation['drawer'] ?? ''}";

              for (final sample in samplesToMove) {
                final updatedSample = sample.copyWith(
                  place: newLocation['place'],
                  location: newLocation['location'],
                  locationid: newLocation['locationid'],
                  drawer: newLocation['drawer'],
                  locationString: locationString,
                );
                moveFutures.add(apiClient.updateSample(jwt, sample: updatedSample));
              }

              await Future.wait(moveFutures);

              if (!context.mounted) return;
              Navigator.of(context).pop();
              toast(context, "${samplesToMove.length} sample(s) moved.", Colors.green);

              ref.invalidate(userSamplesProvider);
              ref.invalidate(allSamplesProvider);
              pageController.clearSelection();
              pageController.toggleSelectionMode();

            } catch (e) {
              if (!context.mounted) return;
              Navigator.of(context).pop();
              toast(context, "Error moving samples: $e", Colors.red);
            }
          },
          label: 'Move',
        ),
      ],
    );
  }
}
