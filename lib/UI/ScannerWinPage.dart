import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

import '../models/Sample.dart';
import 'ScannerPage.dart'; // Reusing the controller from the other scanner page
import 'myMoveDialog.dart';

class ScannerWinPage extends ConsumerWidget {
  const ScannerWinPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(scannerPageControllerProvider);
    final pageController = ref.read(scannerPageControllerProvider.notifier);
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Batch Scanning (Desktop)')),
      body: Column(
        children: [
          // Input Fields
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Scan with wedge scanner or enter manually',
                icon: Icon(Icons.keyboard),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  pageController.addSamplesByCodes([text]);
                  textController.clear();
                }
              },
            ),
          ),

          // Barcode Listener for wedge scanners
          BarcodeKeyboardListener(
            onBarcodeScanned: (barcode) {
              if (barcode.isNotEmpty) {
                pageController.addSamplesByCodes([barcode]);
              }
            },
            child: const SizedBox.shrink(), // This widget doesn't need to be visible
          ),

          if (pageState.isLoading) const LinearProgressIndicator(),
          const Divider(),

          // Scanned items list
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
    // This is identical to the one in ScannerPage.dart
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: samples.isNotEmpty,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.battery_full, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () async {
            // TODO: Implement Empty Cells logic
          },
          label: 'Empty cells',
        ),
        SpeedDialChild(
          child: const Icon(Icons.train, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            ref.read(samplesToEditProvider.notifier).state = samples;
            showDialog(
              context: context,
              builder: (context) => const MyMoveDialog(keepSelection: true),
            ).then((_) {
              ref.read(scannerPageControllerProvider.notifier).clearSamples();
            });
          },
          label: 'Move Samples',
        ),
      ],
    );
  }
}
