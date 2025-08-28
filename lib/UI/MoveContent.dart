// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../features/auth/auth_repository.dart';
import '../features/samples/sample_providers.dart';
import '../models/Sample.dart';
import '../providers.dart';
import 'Toast.dart';
import 'data.dart';

class MoveContent extends ConsumerStatefulWidget {
  final Sample sample;

  const MoveContent({super.key, required this.sample});

  @override
  _MoveContentState createState() => _MoveContentState();
}

class _MoveContentState extends ConsumerState<MoveContent> {
  final _fbKey = GlobalKey<FormBuilderState>();

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
    _initializeDropdowns();
  }

  void _initializeDropdowns() {
    // Initialize with the sample's current location or defaults
    place = widget.sample.place ?? "Confinement";
    _onPlaceChanged(place, initial: true);
    location = widget.sample.location;
    _onLocationChanged(location, initial: true);
    locationid = widget.sample.locationid;
    _onLocationIdChanged(locationid, initial: true);
    drawer = widget.sample.drawer;
  }

  void _onPlaceChanged(String? newValue, {bool initial = false}) {
    if (newValue == null) return;
    setState(() {
      place = newValue;
      if (!initial) {
        location = null;
        locationid = null;
        drawer = null;
      }

      if (place == 'Confinement') locationList = locationOptionsConf;
      else if (place == 'GuideHall') locationList = locationOptionsGuide;
      else if (place == 'Lab') locationList = locationOptionsLab;
      else locationList = locationOptionsOther;

      if (!initial) {
        location = locationList.isNotEmpty ? locationList[0] : null;
        _onLocationChanged(location);
      }
    });
  }

  void _onLocationChanged(String? newValue, {bool initial = false}) {
     if (newValue == null) return;
    setState(() {
      location = newValue;
      if (!initial) {
        locationid = null;
        drawer = null;
      }

      if (location == 'BT1') locationidList = bt1locid;
      else if (location == 'BT2') locationidList = bt2locid;
      // ... (omitting the rest of the giant if/else chain for brevity)
      else locationidList = guideINSTlocid;

      if (!initial) {
        locationid = locationidList.isNotEmpty ? locationidList[0] : null;
        _onLocationIdChanged(locationid);
      }
    });
  }

  void _onLocationIdChanged(String? newValue, {bool initial = false}) {
     if (newValue == null) return;
    setState(() {
      locationid = newValue;
       if (!initial) {
        drawer = null;
      }

      if (locationid == 'Black Cab') drawerList = cabinetdrawer;
      // ... (omitting the rest of the giant if/else chain for brevity)
      else drawerList = [];

      if (!initial) {
        drawer = drawerList.isNotEmpty ? drawerList[0] : null;
      }
    });
  }

  void _onDrawerChanged(String? newValue) {
    if (newValue == null) return;
    setState(() => drawer = newValue);
  }

  Future<void> _submitMove() async {
    if (!_fbKey.currentState!.saveAndValidate()) return;

    final jwt = ref.read(authStateProvider);
    if (jwt == null) {
      toast(context, "Error: Not logged in", Colors.red);
      return;
    }

    // Update the sample object with the new values
    final sampleToUpdate = widget.sample;
    sampleToUpdate.place = place;
    sampleToUpdate.location = location;
    sampleToUpdate.locationid = locationid;
    sampleToUpdate.drawer = drawer;
    sampleToUpdate.date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await ref.read(apiClientProvider).updateSample(jwt, sample: sampleToUpdate);

      ref.invalidate(userSamplesProvider);
      ref.invalidate(allSamplesProvider);

      toast(context, "Sample moved successfully!", Colors.green);
      Navigator.of(context).pop();

    } catch (e) {
      toast(context, "Error moving sample: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Move Sample ID: ${widget.sample.sampleId ?? ''}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _fbKey,
          child: Column(
            children: [
              _buildDropdown('Place', place, placeOptions, _onPlaceChanged),
              _buildDropdown('Location', location, locationList, _onLocationChanged),
              _buildDropdown('Location ID', locationid, locationidList, _onLocationIdChanged),
              _buildDropdown('Drawer/Shelf', drawer, drawerList, _onDrawerChanged),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitMove,
                child: const Text("Submit Move"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        isExpanded: true,
        hint: Text(hint),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }
}