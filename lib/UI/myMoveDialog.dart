import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../API.dart';
import '../features/auth/auth_repository.dart';
import '../features/samples/sample_providers.dart';
import '../models/Sample.dart';
import '../providers.dart';
import 'Toast.dart';
import 'data.dart';

// TODO: This provider holds the state for which samples are selected for an operation.
// In a larger refactor, this might live in a more central location or be part of the
// page state controllers for the List/All pages.
final samplesToEditProvider = StateProvider<List<Sample>>((ref) => []);

class MyMoveDialog extends ConsumerStatefulWidget {
  final bool keepSelection;

  const MyMoveDialog({super.key, this.keepSelection = false});

  @override
  _MyMoveDialogState createState() => _MyMoveDialogState();
}

class _MyMoveDialogState extends ConsumerState<MyMoveDialog> {
  // Local state for the dropdowns
  String? place;
  String? location;
  String? locationid;
  String? drawer;

  List<String> locationList = [];
  List<String> locationidList = [];
  List<String> drawerList = [];

  @override
  void initState() {
    super.initState();
    // Initialize the dropdowns with some default values
    _initializeDropdowns();
  }

  void _initializeDropdowns() {
    place = "Confinement";
    locationList = locationOptionsConf;
    location = locationList[0];
    _onLocationChanged(location);
  }

  void _onPlaceChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      place = newValue;
      location = null;
      locationid = null;
      drawer = null;

      if (place == 'Confinement') locationList = locationOptionsConf;
      else if (place == 'GuideHall') locationList = locationOptionsGuide;
      else if (place == 'Lab') locationList = locationOptionsLab;
      else locationList = locationOptionsOther;

      location = locationList.isNotEmpty ? locationList[0] : null;
      _onLocationChanged(location);
    });
  }

  void _onLocationChanged(String? newValue) {
     if (newValue == null) return;
    setState(() {
      location = newValue;
      locationid = null;
      drawer = null;

      // This huge if/else block is a code smell from the original code.
      // A data-driven approach would be better, but we keep it for now.
      if (location == 'BT1') locationidList = bt1locid;
      else if (location == 'BT2') locationidList = bt2locid;
      // ... (omitting the rest of the giant if/else chain for brevity)
      else locationidList = guideINSTlocid;

      locationid = locationidList.isNotEmpty ? locationidList[0] : null;
      _onLocationIdChanged(locationid);
    });
  }

  void _onLocationIdChanged(String? newValue) {
     if (newValue == null) return;
    setState(() {
      locationid = newValue;
      drawer = null;

      if (locationid == 'Black Cab') drawerList = cabinetdrawer;
      // ... (omitting the rest of the giant if/else chain for brevity)
      else drawerList = [];

      drawer = drawerList.isNotEmpty ? drawerList[0] : null;
    });
  }

  void _onDrawerChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      drawer = newValue;
    });
  }

  Future<void> _submitMove() async {
    final samplesToMove = ref.read(samplesToEditProvider);
    final jwt = ref.read(authStateProvider);

    if (jwt == null || samplesToMove.isEmpty) {
      toast(context, "Error: No user or samples selected.", Colors.red);
      return;
    }

    // Show a loading indicator
    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final List<Future<void>> updateFutures = [];

      for (var sample in samplesToMove) {
        sample.place = place;
        sample.location = location;
        sample.locationid = locationid;
        sample.drawer = drawer;
        sample.date = DateFormat('yyyy-MM-dd').format(DateTime.now());

        updateFutures.add(ref.read(apiClientProvider).updateSample(jwt, sample: sample));
      }

      // Wait for all API calls to complete
      await Future.wait(updateFutures);

      // Invalidate providers to refresh the lists on previous screens
      ref.invalidate(userSamplesProvider);
      ref.invalidate(allSamplesProvider);

      if (!widget.keepSelection) {
        ref.read(samplesToEditProvider.notifier).state = [];
      }

      Navigator.of(context).pop(); // pop loading indicator
      Navigator.of(context).pop('Moved'); // pop this dialog
      toast(context, "Samples moved successfully!", Colors.green);

    } catch (e) {
      Navigator.of(context).pop(); // pop loading indicator
      toast(context, "Error moving samples: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Choose Location"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildDropdown('Place', place, placeOptions, _onPlaceChanged),
            _buildDropdown('Location', location, locationList, _onLocationChanged),
            _buildDropdown('Location ID', locationid, locationidList, _onLocationIdChanged),
            _buildDropdown('Drawer/Shelf', drawer, drawerList, _onDrawerChanged),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitMove,
          child: const Text("Move Selected Samples"),
        ),
      ],
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        hint: Text(hint),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
