import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../features/auth/auth_repository.dart';
import '../features/samples/sample_providers.dart';
import '../models/Sample.dart';
import '../providers.dart';
import 'DetailPage.dart';
import 'Toast.dart';
import 'adminNavDrawer.dart';

// --- State Management ---

final emptyPageSelectionProvider = StateProvider<Set<String>>((ref) => {});

// --- UI ---

class EmptyPage extends ConsumerWidget {
  const EmptyPage({super.key});

  Future<void> _emptySelectedSamples(BuildContext context, WidgetRef ref) async {
    final selectedIds = ref.read(emptyPageSelectionProvider);
    final samplesToEmpty = ref.read(samplesToEmptyProvider).value ?? [];
    final jwt = ref.read(authStateProvider);

    if (jwt == null || selectedIds.isEmpty) {
      toast(context, "No samples selected.", Colors.orange);
      return;
    }

    final samplesToUpdate = samplesToEmpty.where((s) => selectedIds.contains(s.sampleId)).toList();

    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final List<Future<void>> updateFutures = [];
      for (final sample in samplesToUpdate) {
        // Update sample properties as per original logic
        sample.place = "Lab";
        sample.location = "B147";
        sample.locationid = "Decision needed";
        sample.drawer = "";
        sample.cellbarcode = "";
        sample.sampenvbarcode = "";
        sample.date = DateFormat('yyyy-MM-dd').format(DateTime.now());

        updateFutures.add(ref.read(apiClientProvider).updateSample(jwt, sample: sample));
      }

      await Future.wait(updateFutures);

      // Clear selection and refresh data
      ref.read(emptyPageSelectionProvider.notifier).state = {};
      ref.invalidate(samplesToEmptyProvider);
      ref.invalidate(allSamplesProvider); // Invalidate this too as it's the source

      Navigator.of(context).pop(); // pop loading indicator
      toast(context, "Selected samples have been emptied.", Colors.green);

    } catch (e) {
      Navigator.of(context).pop(); // pop loading indicator
      toast(context, "An error occurred: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samplesAsync = ref.watch(samplesToEmptyProvider);
    final selectedIds = ref.watch(emptyPageSelectionProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Empty Samples')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(samplesToEmptyProvider.future),
        child: samplesAsync.when(
          data: (samples) {
            if (samples.isEmpty) {
              return const Center(child: Text("No samples are 'Ready to Unload'."));
            }
            return ListView.builder(
              itemCount: samples.length,
              itemBuilder: (context, index) {
                final sample = samples[index];
                final isSelected = selectedIds.contains(sample.sampleId);
                return Container(
                  color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                  child: ListTile(
                    title: Text(sample.chemical ?? 'No Name'),
                    subtitle: Text('ID: ${sample.sampleId}'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      final currentSelection = Set<String>.from(selectedIds);
                      if (isSelected) {
                        currentSelection.remove(sample.sampleId);
                      } else {
                        currentSelection.add(sample.sampleId!);
                      }
                      ref.read(emptyPageSelectionProvider.notifier).state = currentSelection;
                    },
                    onLongPress: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(sample: sample)));
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error loading samples: $err")),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedIds.isEmpty ? null : () => _emptySelectedSamples(context, ref),
        backgroundColor: selectedIds.isEmpty ? Colors.grey : Theme.of(context).primaryColor,
        child: const Icon(Icons.check),
      ),
    );
  }
}
