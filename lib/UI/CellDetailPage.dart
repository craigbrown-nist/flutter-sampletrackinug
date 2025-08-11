// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_samples/features/samples/sample_providers.dart';

import '../models/Cells.dart';
import '../features/auth/auth_repository.dart';
import '../providers.dart';
import 'DetailPage.dart';

class CellDetailPage extends ConsumerWidget {
  final Cells cell;
  final double kExpandedHeight = 200.0;

  const CellDetailPage({super.key, required this.cell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool noSampleIn = cell.sample?.sampleId == null || cell.sample!.sampleId!.isEmpty;
    final String imageURL = cell.sample?.imageURL ?? "";
    final String localImage = _getLocalImageForCell(cell.description);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _buildSliverAppBar(context, localImage, imageURL),
          noSampleIn
              ? _buildNoSampleContent(context, ref)
              : _buildSampleContent(context),
        ],
      ),
    );
  }

  String _getLocalImageForCell(String? description) {
    switch (description) {
      case "Vanadium A":
      case "Vanadium B":
      case "Vanadium C":
      case "Vanadium D":
      case "Vanadium E":
        return "assets/images/V-cells.jpg";
      case "Brookhaven SC":
      case "Single Crystal Small":
      case "Single Crystal Large":
        return "assets/images/Brookhaven.jpg";
      case "Al 6.3cc":
      case "Al 3.1cc":
      case "Al 1.6cc":
      case "Al 1.2cc":
        return "assets/images/Al-cans.jpg";
      case "DCS Al":
        return "assets/images/dcs-can.jpg";
      default:
        return "assets/images/ncnr.jpg";
    }
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, String localImage, String imageURL) {
    return SliverAppBar(
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      expandedHeight: kExpandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Barcode: ${cell.barcode!}', style: const TextStyle(fontSize: 10.0)),
            Text(cell.description!, style: const TextStyle(fontSize: 16.0)),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            imageURL.isNotEmpty
                ? Image.network(imageURL, fit: BoxFit.contain)
                : Image.asset(localImage, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, 0.8),
                  end: Alignment(0.0, 0.2),
                  colors: <Color>[Color(0x60000000), Color(0x00000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSampleContent(BuildContext context, WidgetRef ref) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('No sample currently in this cell', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Cell'),
                onPressed: () async {
                  final bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: Text('Are you sure you want to delete cell ${cell.barcode}?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      final jwt = ref.read(authStateProvider);
                      await ref.read(apiClientProvider).deleteCell(jwt!, id: cell.id!);

                      ref.invalidate(fullCellsProvider);
                      ref.invalidate(emptyCellsProvider);

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cell deleted successfully'), backgroundColor: Colors.green));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting cell: $e'), backgroundColor: Colors.red));
                    }
                  }
                },
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget _buildSampleContent(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        ListTile(
          leading: const Icon(Icons.check_circle),
          title: const Text('Chemical:'),
          subtitle: Text('${cell.sample!.chemical!} (${cell.sample!.sampleName!})'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailPage(sample: cell.sample!)),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.local_library),
          title: const Text('Owner:'),
          subtitle: Text('${cell.sample!.owner!} (${cell.sample!.username!})'),
        ),
        ListTile(
          leading: const Icon(Icons.gps_fixed),
          title: const Text('Located:'),
          subtitle: Text(cell.sample!.locationString!),
        ),
        ListTile(
          leading: const Icon(Icons.fitness_center),
          title: const Text('Mass:'),
          subtitle: Text('${cell.sample!.quantity!} ${cell.sample!.unit!} (${cell.sample!.form!})'),
        ),
      ]),
    );
  }
}
