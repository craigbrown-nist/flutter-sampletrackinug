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
    // Initialize dropdowns with existing data, populating all lists correctly.
    _initializeDropdowns();
  }

  void _initializeDropdowns() {
    place = widget.sample.place ?? "Confinement";
    if (place == 'Confinement') {
      locationList = locationOptionsConf;
    } else if (place == 'GuideHall') {
      locationList = locationOptionsGuide;
    } else if (place == 'Lab') {
      locationList = locationOptionsLab;
    } else {
      locationList = locationOptionsOther;
    }

    location = widget.sample.location;
    // Full logic for location -> locationid
    if (location == 'BT1') {
      locationidList = bt1locid;
    } else if (location == 'BT2') {
      locationidList = bt2locid;
    } else if (location == 'BT4') {
      locationidList = bt4locid;
    } else if (location == 'BT5') {
      locationidList = bt5locid;
    } else if (location == 'BT7') {
      locationidList = bt7locid;
    } else if (location == 'BT8') {
      locationidList = bt8locid;
    } else if (location == 'MACS') {
      locationidList = macslocid;
    } else if (location == 'East') {
      locationidList = guideEASTlocid;
    } else if (location == 'North') {
      locationidList = guideNORTHlocid;
    } else if (location == 'SPINS') {
      locationidList = guideSPINSlocid;
    } else if (location == 'Polar') {
      locationidList = guidePOLARlocid;
    } else if (location == 'A115') {
      locationidList = a115locid;
    } else if (location == 'A117') {
      locationidList = a117locid;
    } else if (location == 'A127') {
      locationidList = a127locid;
    } else if (location == 'A132') {
      locationidList = a132locid;
    } else if (location == 'B147') {
      locationidList = b147locid;
    } else if (location == 'B142') {
      locationidList = b142locid;
    } else if (location == 'E131') {
      locationidList = e131locid;
    } else if (location == 'E133') {
      locationidList = e133locid;
    } else if (location == 'E132') {
      locationidList = e132locid;
    } else if (location == 'E134') {
      locationidList = e134locid;
    } else if (location == 'E135') {
      locationidList = e135locid;
    } else if (location == 'E136') {
      locationidList = e136locid;
    } else if (location == 'E137') {
      locationidList = e137locid;
    } else if (location == 'E138') {
      locationidList = e138locid;
    } else if (location == 'HP_Clear') {
      locationidList = hplocid;
    } else if (location == 'Shipped back') {
      locationidList = shiplocid;
    } else if (location == 'Waste') {
      locationidList = [""];
    } else if (place == 'GuideHall') {
      locationidList = guideINSTlocid;
    } else {
      locationidList = [];
    }

    locationid = widget.sample.locationid;
    // Full logic for locationid -> drawer
    if (locationid == 'Black Cab' ||
        locationid == 'Beige Cab' ||
        locationid == 'Grey Cab') {
      drawerList = cabinetdrawer;
    } else if (locationid == 'Cream Cab' || locationid == 'Cabinet') {
      drawerList = otherdrawer;
    } else if (locationid == 'Bank 2' ||
        locationid == 'Bank 13' ||
        locationid == 'Bank 14' ||
        locationid == 'Bank 15' ||
        locationid == 'Bank 16a' ||
        locationid == 'Bank 16' ||
        locationid == 'Bank 18' ||
        locationid == 'Bank 19' ||
        locationid == 'Bank 17' ||
        locationid == 'Bank 4' ||
        locationid == 'Bank 7' ||
        locationid == 'Bank 20' ||
        locationid == 'Bank 21' ||
        locationid == 'Bank 22' ||
        locationid == 'Bank 23' ||
        locationid == 'Bank 24' ||
        locationid == 'Bank 25' ||
        locationid == 'Bank 26') {
      drawerList = bankdrawer;
    } else if (locationid == 'Freezer') {
      drawerList = drawer5;
    } else if (locationid == 'Argon box' ||
        locationid == 'Freezer4-Left' ||
        locationid == 'Freezer4-Right') {
      drawerList = drawer4;
    } else if (locationid == 'Fridge-Left' || locationid == 'Fridge-Right') {
      drawerList = drawer6;
    } else {
      drawerList = [];
    }

    drawer = widget.sample.drawer;
  }

  void _onPlaceChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      place = newValue;

      // Determine the new list of locations.
      if (place == 'Confinement') {
        locationList = locationOptionsConf;
      } else if (place == 'GuideHall') {
        locationList = locationOptionsGuide;
      } else if (place == 'Lab') {
        locationList = locationOptionsLab;
      } else {
        locationList = locationOptionsOther;
      }

      // Reset children and cascade the update.
      location = locationList.isNotEmpty ? locationList.first : null;
      // Manually trigger the next dropdown's update logic.
      _onLocationChanged(location);
    });
  }

  void _onLocationChanged(String? newValue) {
    setState(() {
      location = newValue;

      // Full logic for location -> locationid
      if (location == 'BT1') {
        locationidList = bt1locid;
      } else if (location == 'BT2') {
        locationidList = bt2locid;
      } else if (location == 'BT4') {
        locationidList = bt4locid;
      } else if (location == 'BT5') {
        locationidList = bt5locid;
      } else if (location == 'BT7') {
        locationidList = bt7locid;
      } else if (location == 'BT8') {
        locationidList = bt8locid;
      } else if (location == 'MACS') {
        locationidList = macslocid;
      } else if (location == 'East') {
        locationidList = guideEASTlocid;
      } else if (location == 'North') {
        locationidList = guideNORTHlocid;
      } else if (location == 'SPINS') {
        locationidList = guideSPINSlocid;
      } else if (location == 'Polar') {
        locationidList = guidePOLARlocid;
      } else if (location == 'A115') {
        locationidList = a115locid;
      } else if (location == 'A117') {
        locationidList = a117locid;
      } else if (location == 'A127') {
        locationidList = a127locid;
      } else if (location == 'A132') {
        locationidList = a132locid;
      } else if (location == 'B147') {
        locationidList = b147locid;
      } else if (location == 'B142') {
        locationidList = b142locid;
      } else if (location == 'E131') {
        locationidList = e131locid;
      } else if (location == 'E133') {
        locationidList = e133locid;
      } else if (location == 'E132') {
        locationidList = e132locid;
      } else if (location == 'E134') {
        locationidList = e134locid;
      } else if (location == 'E135') {
        locationidList = e135locid;
      } else if (location == 'E136') {
        locationidList = e136locid;
      } else if (location == 'E137') {
        locationidList = e137locid;
      } else if (location == 'E138') {
        locationidList = e138locid;
      } else if (location == 'HP_Clear') {
        locationidList = hplocid;
      } else if (location == 'Shipped back') {
        locationidList = shiplocid;
      } else if (location == 'Waste') {
        locationidList = [""];
      } else if (place == 'GuideHall') {
        locationidList = guideINSTlocid;
      } else {
        locationidList = [];
      }

      locationid = locationidList.isNotEmpty ? locationidList.first : null;
      _onLocationIdChanged(locationid);
    });
  }

  void _onLocationIdChanged(String? newValue) {
    setState(() {
      locationid = newValue;

      // Full logic for locationid -> drawer
      if (locationid == 'Black Cab' ||
          locationid == 'Beige Cab' ||
          locationid == 'Grey Cab') {
        drawerList = cabinetdrawer;
      } else if (locationid == 'Cream Cab' || locationid == 'Cabinet') {
        drawerList = otherdrawer;
      } else if (locationid == 'Bank 2' ||
          locationid == 'Bank 13' ||
          locationid == 'Bank 14' ||
          locationid == 'Bank 15' ||
          locationid == 'Bank 16a' ||
          locationid == 'Bank 16' ||
          locationid == 'Bank 18' ||
          locationid == 'Bank 19' ||
          locationid == 'Bank 17' ||
          locationid == 'Bank 4' ||
          locationid == 'Bank 7' ||
          locationid == 'Bank 20' ||
          locationid == 'Bank 21' ||
          locationid == 'Bank 22' ||
          locationid == 'Bank 23' ||
          locationid == 'Bank 24' ||
          locationid == 'Bank 25' ||
          locationid == 'Bank 26') {
        drawerList = bankdrawer;
      } else if (locationid == 'Freezer') {
        drawerList = drawer5;
      } else if (locationid == 'Argon box' ||
          locationid == 'Freezer4-Left' ||
          locationid == 'Freezer4-Right') {
        drawerList = drawer4;
      } else if (locationid == 'Fridge-Left' || locationid == 'Fridge-Right') {
        drawerList = drawer6;
      } else {
        drawerList = [];
      }

      drawer = drawerList.isNotEmpty ? drawerList.first : null;
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

    // Construct the new location string from the current state
    final newLocationString =
        "${place ?? ''}/${location ?? ''}/${locationid ?? ''}/${drawer ?? ''}";

    // Create an updated sample object using copyWith
    final sampleToUpdate = widget.sample.copyWith(
      place: place,
      location: location,
      locationid: locationid,
      drawer: drawer,
      locationString: newLocationString,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    try {
      await ref.read(apiClientProvider).updateSample(jwt, sample: sampleToUpdate);

      ref.invalidate(userSamplesProvider);
      ref.invalidate(allSamplesProvider);

      toast(context, "Sample moved successfully!", Colors.green);
      Navigator.of(context).pop(sampleToUpdate);

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