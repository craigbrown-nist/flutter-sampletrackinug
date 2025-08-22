import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/Sample.dart';
import 'data.dart';

class MoveDialogContent extends ConsumerStatefulWidget {
  // Pass an optional sample to set the initial dropdown values.
  // If null, will use default values.
  final Sample? initialSample;

  const MoveDialogContent({super.key, this.initialSample});

  @override
  _MoveDialogContentState createState() => _MoveDialogContentState();
}

class _MoveDialogContentState extends ConsumerState<MoveDialogContent> {
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
    // Use initialSample if provided, otherwise use defaults.
    place = widget.initialSample?.place ?? "Confinement";
    if (place == 'Confinement') {
      locationList = locationOptionsConf;
    } else if (place == 'GuideHall') {
      locationList = locationOptionsGuide;
    } else if (place == 'Lab') {
      locationList = locationOptionsLab;
    } else {
      locationList = locationOptionsOther;
    }

    location = widget.initialSample?.location;
    if (!locationList.contains(location)) {
        location = locationList.isNotEmpty ? locationList.first : null;
    }

    _updateLocationIdList();
    locationid = widget.initialSample?.locationid;
    if (!locationidList.contains(locationid)) {
        locationid = locationidList.isNotEmpty ? locationidList.first : null;
    }

    _updateDrawerList();
    drawer = widget.initialSample?.drawer;
    if (!drawerList.contains(drawer)) {
        drawer = drawerList.isNotEmpty ? drawerList.first : null;
    }
  }

  void _updateLocationIdList() {
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
  }

  void _updateDrawerList() {
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
  }

  void _onPlaceChanged(String? newValue) {
    if (newValue == null || newValue == place) return;
    setState(() {
      place = newValue;
      if (place == 'Confinement') {
        locationList = locationOptionsConf;
      } else if (place == 'GuideHall') {
        locationList = locationOptionsGuide;
      } else if (place == 'Lab') {
        locationList = locationOptionsLab;
      } else {
        locationList = locationOptionsOther;
      }
      location = locationList.isNotEmpty ? locationList.first : null;
      _onLocationChanged(location);
    });
  }

  void _onLocationChanged(String? newValue) {
    // This can be called with the same value, so we need a guard.
    // We also need to call it directly to cascade updates.
    setState(() {
      location = newValue;
      _updateLocationIdList();
      locationid = locationidList.isNotEmpty ? locationidList.first : null;
      _onLocationIdChanged(locationid);
    });
  }

  void _onLocationIdChanged(String? newValue) {
     setState(() {
      locationid = newValue;
      _updateDrawerList();
      drawer = drawerList.isNotEmpty ? drawerList.first : null;
    });
  }

  void _onDrawerChanged(String? newValue) {
    if (newValue == null) return;
    setState(() => drawer = newValue);
  }

  void _onConfirm() {
    final locationData = {
      'place': place,
      'location': location,
      'locationid': locationid,
      'drawer': drawer,
    };
    Navigator.of(context).pop(locationData);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Move Selected Samples'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          onPressed: _onConfirm,
          child: const Text('OK'),
        ),
      ],
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
        decoration: InputDecoration(
          labelText: hint,
          border: const OutlineInputBorder()
        ),
      ),
    );
  }
}
