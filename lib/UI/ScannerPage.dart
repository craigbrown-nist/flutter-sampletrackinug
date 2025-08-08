import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../API.dart';
import '../Functions/barcode_scanner_controller.dart';
import '../features/auth/auth_repository.dart';
import '../features/samples/sample_providers.dart';
import '../models/Sample.dart';
import '../providers.dart';
import 'myMoveDialog.dart';
import 'Toast.dart';

// --- State Management ---

class ScannerPageState {
  final List<Sample> scannedSamples;
  final bool isLoading;

  ScannerPageState({this.scannedSamples = const [], this.isLoading = false});

  ScannerPageState copyWith({List<Sample>? scannedSamples, bool? isLoading}) {
    return ScannerPageState(
      scannedSamples: scannedSamples ?? this.scannedSamples,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ScannerPageController extends StateNotifier<ScannerPageState> {
  final ApiClient _apiClient;
  final String? _jwt;
  final String? _userEmail;
  final bool _isAdmin;

  ScannerPageController(this._apiClient, this._jwt, this._userEmail, this._isAdmin)
      : super(ScannerPageState());

  Future<void> addSamplesByCodes(List<String> codes) async {
    if (_jwt == null) return;
    state = state.copyWith(isLoading: true);

    final existingIds = state.scannedSamples.map((s) => s.sampleId).toSet();

    for (final code in codes) {
      if (existingIds.contains(code)) continue; // Skip duplicates

      try {
        final sample = await _apiClient.getSampleID(_jwt!, id: code);
        if (sample.owner == _userEmail || _isAdmin) {
          state = state.copyWith(
            scannedSamples: [...state.scannedSamples, sample],
          );
          existingIds.add(sample.sampleId!);
        } else {
          // Handle case where user doesn't have access
        }
      } catch (e) {
        // Handle error fetching sample
      }
    }
    state = state.copyWith(isLoading: false);
  }

  void removeSample(Sample sample) {
    state = state.copyWith(
      scannedSamples: state.scannedSamples.where((s) => s.sampleId != sample.sampleId).toList(),
    );
  }

  void clearSamples() {
    state = state.copyWith(scannedSamples: []);
  }
}

final scannerPageControllerProvider =
    StateNotifierProvider<ScannerPageController, ScannerPageState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final jwt = ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider).value;
  return ScannerPageController(apiClient, jwt, user?.email, user?.manager == '1');
});


// --- UI ---

class ScannerPage extends ConsumerWidget {
  const ScannerPage({super.key});

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final dynamic response = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerWithController(single: 0),
      ),
    );

    if (response != null && response is List<String>) {
      await ref.read(scannerPageControllerProvider.notifier).addSamplesByCodes(response);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(scannerPageControllerProvider);
    final pageController = ref.read(scannerPageControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Continuous Sample Scanning')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Scanning'),
              onPressed: () => _scan(context, ref),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ),
          if (pageState.isLoading) const LinearProgressIndicator(),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Scanned Samples (Tap to remove)"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pageState.scannedSamples.length,
              itemBuilder: (context, index) {
                final sample = pageState.scannedSamples[index];
                return ListTile(
                  leading: Text(sample.sampleId ?? 'N/A'),
                  title: Text(sample.sampleName ?? 'No Name'),
                  onTap: () => pageController.removeSample(sample),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSpeedDial(context, ref, pageState.scannedSamples),
    );
  }

  SpeedDial _buildSpeedDial(BuildContext context, WidgetRef ref, List<Sample> samples) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: samples.isNotEmpty,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.battery_full, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () async {
            // TODO: Implement Empty Cells logic with new architecture
            toast(context, "Not Implemented Yet", Colors.grey);
          },
          label: 'Empty cells',
        ),
        SpeedDialChild(
          child: const Icon(Icons.train, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            // Set the samples to be moved and show the dialog
            ref.read(samplesToEditProvider.notifier).state = samples;
            showDialog(
              context: context,
              builder: (context) => const MyMoveDialog(keepSelection: true),
            ).then((_) {
              // After dialog is closed, clear the selection on this page
              ref.read(scannerPageControllerProvider.notifier).clearSamples();
            });
          },
          label: 'Move Samples',
        ),
      ],
    );
  }
}
