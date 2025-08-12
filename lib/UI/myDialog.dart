import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_samples/features/samples/sample_providers.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../features/auth/auth_repository.dart';
import '../features/cells/cells_page_state.dart';
import '../providers.dart';
import 'Toast.dart';
// Note: BarcodeScannerWithController would also need refactoring in a full project rewrite.
import '../Functions/barcode_scanner_controller.dart';

class MyCellDialog extends ConsumerStatefulWidget {
  const MyCellDialog({super.key});

  @override
  _MyCellDialogState createState() => _MyCellDialogState();
}

class _MyCellDialogState extends ConsumerState<MyCellDialog> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();

  // The list of cell types is now defined statically in the CellsPageState
  String _selectedCellType = CellsPageState.cellTypes[0];

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final jwt = ref.read(authStateProvider);
    if (jwt == null) {
      toast(context, "Error: Not logged in", Colors.red);
      return;
    }

    try {
      await ref.read(apiClientProvider).addNewCell(
        jwt,
        barcode: _barcodeController.text,
        description: _selectedCellType,
      );

      // Invalidate providers to trigger a refresh on the previous screen
      ref.invalidate(fullCellsProvider);
      ref.invalidate(emptyCellsProvider);

      toast(context, "Cell added successfully", Colors.green);
      Navigator.of(context).pop();

    } catch (e) {
      toast(context, "Error adding cell: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _barcodeController,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Barcode',
                suffixIcon: IconButton(
                  icon:   Icon(MdiIcons.qrcodeScan, color: Colors.blue),
                  onPressed: () async {
                    final dynamic response = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MobileScannerPicklist(single: 1),
                      ),
                    );
                    if (response != null && response is String) {
                      _barcodeController.text = response;
                    }
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Barcode cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCellType,
              items: CellsPageState.cellTypes.map((label) {
                return DropdownMenuItem<String>(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCellType = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Cell Type'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

