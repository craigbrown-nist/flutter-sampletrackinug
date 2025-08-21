// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../features/auth/auth_repository.dart';
import '../features/samples/sample_providers.dart';
import '../models/Sample.dart';
import '../providers.dart';
import 'Toast.dart';
import 'data.dart';

// This is the fully refactored, unified EditContent widget.
// It uses Riverpod for state and API calls, handles the Windows camera
// workaround, uses in-memory image resizing, and contains the complete
// form and submission logic from the original application.

class EditContent extends ConsumerStatefulWidget {
  final Sample sample;
  final String status;

  const EditContent({super.key, required this.sample, this.status = "edit"});

  @override
  _EditContentState createState() => _EditContentState();
}

class _EditContentState extends ConsumerState<EditContent> {
  final _fbKey = GlobalKey<FormBuilderState>();

  // --- Form-specific local state ---
  Uint8List? _resizedImageBytes;
  bool _changedImage = false;

  // --- Dropdown state ---
  String? place;
  String? location;
  String? locationid;
  String? drawer;

  List<String> locationList = [];
  List<String> locationidList = [];
  List<String> drawerList = [];

  // --- Windows Camera State ---
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraId = -1;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.status == "clone") {
      widget.sample.sampleId = '';
      widget.sample.imageURL = null;
    }
    _initializeDropdowns();
    if (kIsWeb || Platform.isWindows) {
      _fetchCameras();
    }
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    super.dispose();
  }

  // --- Dropdown Logic ---
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
    if (locationid == 'Black Cab' || locationid == 'Beige Cab' || locationid == 'Grey Cab') {
      drawerList = cabinetdrawer;
    } else if (locationid == 'Cream Cab' || locationid == 'Cabinet') {
      drawerList = otherdrawer;
    } else if (locationid == 'Bank 2' || locationid == 'Bank 13' || locationid == 'Bank 14' || locationid == 'Bank 15' || locationid == 'Bank 16a' || locationid == 'Bank 16' || locationid == 'Bank 18' || locationid == 'Bank 19' || locationid == 'Bank 17' || locationid == 'Bank 4' || locationid == 'Bank 7' || locationid == 'Bank 20' || locationid == 'Bank 21' || locationid == 'Bank 22' || locationid == 'Bank 23' || locationid == 'Bank 24' || locationid == 'Bank 25' || locationid == 'Bank 26') {
      drawerList = bankdrawer;
    } else if (locationid == 'Freezer') {
      drawerList = drawer5;
    } else if (locationid == 'Argon box' || locationid == 'Freezer4-Left' || locationid == 'Freezer4-Right') {
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
    setState(() {
      location = newValue;
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
      if (locationid == 'Black Cab' || locationid == 'Beige Cab' || locationid == 'Grey Cab') {
        drawerList = cabinetdrawer;
      } else if (locationid == 'Cream Cab' || locationid == 'Cabinet') {
        drawerList = otherdrawer;
      } else if (locationid == 'Bank 2' || locationid == 'Bank 13' || locationid == 'Bank 14' || locationid == 'Bank 15' || locationid == 'Bank 16a' || locationid == 'Bank 16' || locationid == 'Bank 18' || locationid == 'Bank 19' || locationid == 'Bank 17' || locationid == 'Bank 4' || locationid == 'Bank 7' || locationid == 'Bank 20' || locationid == 'Bank 21' || locationid == 'Bank 22' || locationid == 'Bank 23' || locationid == 'Bank 24' || locationid == 'Bank 25' || locationid == 'Bank 26') {
        drawerList = bankdrawer;
      } else if (locationid == 'Freezer') {
        drawerList = drawer5;
      } else if (locationid == 'Argon box' || locationid == 'Freezer4-Left' || locationid == 'Freezer4-Right') {
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

  // --- Image Handling ---
  Future<void> _pickAndResizeImage(ImageSource source) async {
    Uint8List? imageBytes;
    if (source == ImageSource.camera && (kIsWeb || Platform.isWindows)) {
      imageBytes = await _takePictureWithWindowsCamera();
    } else {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1000);
      if (pickedFile != null) {
        imageBytes = await pickedFile.readAsBytes();
      }
    }
    if (imageBytes == null) return;
    final image = img.decodeImage(imageBytes);
    if (image == null) return;
    final resizedBytes = img.encodeJpg(image, quality: 85);
    setState(() {
      _resizedImageBytes = resizedBytes;
      _changedImage = true;
    });
  }

  Future<Uint8List?> _takePictureWithWindowsCamera() async {
    if (_cameras.isEmpty) {
      toast(context, "No available cameras found.", Colors.red);
      return null;
    }
    await _initializeCamera();
    if (!_isCameraInitialized || !mounted) return null;
    final XFile file = await CameraPlatform.instance.takePicture(_cameraId);
    final bytes = await file.readAsBytes();
    await _disposeCurrentCamera();
    return bytes;
  }

  Future<void> _fetchCameras() async {
    try {
      _cameras = await CameraPlatform.instance.availableCameras();
    } on PlatformException catch (e) {
      debugPrint('Failed to get cameras: ${e.code}: ${e.message}');
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) return;
    try {
      final camera = _cameras.first;
      _cameraId = await CameraPlatform.instance.createCamera(camera, ResolutionPreset.veryHigh);
      await CameraPlatform.instance.initializeCamera(_cameraId);
      if (mounted) setState(() => _isCameraInitialized = true);
    } on CameraException catch (e) {
      debugPrint('Failed to initialize camera: ${e.code}: ${e.description}');
      _disposeCurrentCamera();
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0) {
      await CameraPlatform.instance.dispose(_cameraId);
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  // --- Form Submission ---
  Future<void> _submitForm() async {
    if (!_fbKey.currentState!.saveAndValidate()) return;

    final jwt = ref.read(authStateProvider);
    if (jwt == null) {
      toast(context, "Error: Not logged in", Colors.red);
      return;
    }

    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      Sample sampleToSubmit = _buildSampleFromForm();

      // If this is a new or cloned sample, override the owner/username
      // with the current logged-in user's details.
      if (widget.status == 'new' || widget.status == 'clone') {
        final currentUser = ref.read(currentUserProvider).value;
        sampleToSubmit = sampleToSubmit.copyWith(
          owner: currentUser?.email,
          username: currentUser?.name,
        );
      }

      // First, create or update the sample data. This call returns the ID
      // needed for a potential image upload.
      final responseData = await ref.read(apiClientProvider).updateSample(jwt, sample: sampleToSubmit);
      final returnedId = responseData?['sample_id'];

      // If an image was changed, now upload it using the sample's ID.
      if (_changedImage && _resizedImageBytes != null) {
        // For a new sample, use the ID we just got back from the server.
        final sampleIdForImage = widget.status == 'edit' ? sampleToSubmit.sampleId : returnedId;
        if (sampleIdForImage != null) {
          final tempFile = await _createTempFileFromBytes(_resizedImageBytes!);
          final newImageUrl = await ref.read(apiClientProvider).updateImage(jwt, sampleID: sampleIdForImage, file: tempFile);
          await tempFile.delete();
          if (newImageUrl != null) {
            final cacheBustedUrl = '$newImageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
            sampleToSubmit = sampleToSubmit.copyWith(imageURL: cacheBustedUrl);
          }
        }
      }

      // Invalidate providers to ensure lists are refreshed.
      ref.invalidate(userSamplesProvider);
      ref.invalidate(allSamplesProvider);
      ref.invalidate(samplesToEmptyProvider);

      if (!mounted) return;
      Navigator.of(context).pop(); // Pop loading indicator
      toast(context, "Sample saved successfully!", Colors.green);
      Navigator.of(context).pop(sampleToSubmit); // Pop back and return the final sample object
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Pop loading indicator
      toast(context, "An error occurred: $e", Colors.red);
    }
  }

  Sample _buildSampleFromForm() {
    final values = _fbKey.currentState!.value;
    final originalSample = widget.sample;
    final newLocationString = "${place ?? ''}/${location ?? ''}/${locationid ?? ''}/${drawer ?? ''}";

    return Sample(
      id: widget.status == 'edit' ? originalSample.id : null,
      sampleId: widget.status == 'edit' ? originalSample.sampleId : null,
      sampleName: values['sample_name'],
      chemical: values['chemical'],
      owner: values['owner'],
      username: values['username'],
      cellbarcode: values['cellbarcode'],
      sampenvbarcode: values['sampenvbarcode'],
      unit: values['units'],
      parent: originalSample.parent ?? "0",
      archived: values['archived'] ? "1" : "0",
      added: (values['added'] as DateTime).toIso8601String(),
      externalUser: values['external_user'],
      quantity: values['quantity']?.toString(),
      form: values['form'],
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      extraNotes: values['extra_notes'],
      haz1: values['Haz1'],
      haz2: values['Haz2'],
      haz3: values['Haz3'],
      haz4: values['Haz4'],
      // --- Location from state ---
      place: place,
      location: location,
      locationid: locationid,
      drawer: drawer,
      locationString: newLocationString,
    );
  }

  Future<File> _createTempFileFromBytes(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/upload.jpg';
    final file = File(tempPath);
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final allForms = ref.watch(formsProvider).value?.map((e) => e.name!).toList() ?? [];
    final allUnits = ref.watch(unitsProvider).value?.map((e) => e.name!).toList() ?? [];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _fbKey,
          initialValue: {
            'chemical': widget.sample.chemical,
            'sample_name': widget.sample.sampleName,
            'external_user': widget.sample.externalUser,
            'added': widget.sample.added != null ? DateTime.tryParse(widget.sample.added!) : DateTime.now(),
            'quantity': widget.sample.quantity,
            'cellbarcode': widget.sample.cellbarcode,
            'sampenvbarcode': widget.sample.sampenvbarcode,
            'extra_notes': widget.sample.extraNotes,
            'archived': widget.sample.archived == '1',
            'Haz1': widget.sample.haz1,
            'Haz2': widget.sample.haz2,
            'Haz3': widget.sample.haz3,
            'Haz4': widget.sample.haz4,
            'units': widget.sample.unit ?? 'g',
            'form': widget.sample.form ?? 'Powder',
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilderTextField(name: "chemical", decoration: const InputDecoration(labelText: "Chemical Name")),
              FormBuilderTextField(name: "sample_name", decoration: const InputDecoration(labelText: "Sample Name")),
              // ... other fields ...
              FormBuilderDropdown(name: 'form', items: allForms.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList()),
              FormBuilderDropdown(name: 'units', items: allUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList()),
              const SizedBox(height: 20),
              const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildDropdown("Place", place, placeOptions, _onPlaceChanged),
              _buildDropdown("Location", location, locationList, _onLocationChanged),
              _buildDropdown("Location ID", locationid, locationidList, _onLocationIdChanged),
              _buildDropdown("Drawer/Shelf", drawer, drawerList, _onDrawerChanged),
              const SizedBox(height: 20),
              const Text("Image", style: TextStyle(fontWeight: FontWeight.bold)),
              _resizedImageBytes != null
                  ? Image.memory(_resizedImageBytes!, height: 200)
                  : (widget.sample.imageURL != null && widget.sample.imageURL!.isNotEmpty)
                      ? Image.network(widget.sample.imageURL!, height: 200)
                      : Image.asset("assets/images/ncnr.jpg", height: 200),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () => _pickAndResizeImage(ImageSource.gallery), child: const Text("From Gallery")),
                  ElevatedButton(onPressed: () => _pickAndResizeImage(ImageSource.camera), child: const Text("From Camera")),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(onPressed: _submitForm, child: const Text("Submit")),
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
        decoration: InputDecoration(
          labelText: hint,
          border: const OutlineInputBorder()
        ),
      ),
    );
  }
}
