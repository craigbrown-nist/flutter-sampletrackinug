import 'dart:async';
import 'dart:io';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package.flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../API.dart';
import '../features/auth/auth_repository.dart';
import '../models/Sample.dart';
import '../providers.dart';
import 'Toast.dart';
import 'data.dart';

// This is the unified EditContent widget, designed to work on all platforms.
// It incorporates the Windows-specific camera logic while using a modern,
// in-memory image handling approach.

class EditContent extends ConsumerStatefulWidget {
  final Sample? sample;
  final String status;

  const EditContent({super.key, this.sample, required this.status});

  @override
  _EditContentState createState() => _EditContentState();
}

class _EditContentState extends ConsumerState<EditContent> {
  final _fbKey = GlobalKey<FormBuilderState>();

  // --- Image State ---
  Uint8List? _resizedImageBytes;
  bool _changedImage = false;

  // --- Windows Camera State ---
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _isCameraInitialized = false;
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;

  // --- Other State ---
  // Note: A full refactor would move much of this into a StateNotifier.
  String unit = "";
  String form = "";
  // ... other form state variables

  @override
  void initState() {
    super.initState();
    if (kIsWeb || Platform.isWindows) {
      _fetchCameras();
    }
    // The huge block of initialization logic from the original file would go here.
    // For brevity, we are focusing on the camera logic.
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _cameraClosingStreamSubscription?.cancel();
    super.dispose();
  }

  // --- UNIFIED IMAGE PICKING LOGIC ---

  Future<void> _pickImage(ImageSource source) async {
    Uint8List? imageBytes;

    if (source == ImageSource.camera && (kIsWeb || Platform.isWindows)) {
      // Use low-level Windows implementation
      imageBytes = await _takePictureWithWindowsCamera();
    } else {
      // Use image_picker for mobile gallery/camera and desktop gallery
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        imageBytes = await pickedFile.readAsBytes();
      }
    }

    if (imageBytes == null) return;

    // Resize the image in memory
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      toast(context, "Could not decode image.", Colors.red);
      return;
    }

    final resizedImage = img.copyResize(image, width: 1000);
    final resizedBytes = img.encodeJpg(resizedImage, quality: 85);

    setState(() {
      _resizedImageBytes = resizedBytes;
      _changedImage = true;
    });
  }

  // --- WINDOWS CAMERA HELPER METHODS (from EditContentWin.dart) ---

  Future<Uint8List?> _takePictureWithWindowsCamera() async {
    if (_cameras.isEmpty) await _fetchCameras();
    if (_cameras.isEmpty) {
      toast(context, "No available cameras found.", Colors.red);
      return null;
    }

    await _initializeCamera();
    if (!_isCameraInitialized) return null;

    final XFile file = await CameraPlatform.instance.takePicture(_cameraId);
    final bytes = await file.readAsBytes();
    await _disposeCurrentCamera();
    return bytes;
  }

  Future<void> _fetchCameras() async {
    try {
      _cameras = await CameraPlatform.instance.availableCameras();
    } on PlatformException catch (e) {
      print('Failed to get cameras: ${e.code}: ${e.message}');
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) return;
    try {
      final cameraIndex = _cameraIndex % _cameras.length;
      final camera = _cameras[cameraIndex];

      _cameraId = await CameraPlatform.instance.createCamera(camera, ResolutionPreset.veryHigh);
      await CameraPlatform.instance.initializeCamera(_cameraId);

      if (mounted) setState(() => _isCameraInitialized = true);
    } on CameraException catch (e) {
      print('Failed to initialize camera: ${e.code}: ${e.description}');
      _disposeCurrentCamera();
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0) {
      await CameraPlatform.instance.dispose(_cameraId);
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  // --- SUBMIT LOGIC ---

  Future<void> _submitForm() async {
    if (!_fbKey.currentState!.saveAndValidate()) return;

    final jwt = ref.read(authStateProvider);
    if (jwt == null) {
      toast(context, "Error: Not logged in", Colors.red);
      return;
    }

    // This is where the massive logic for collecting all form fields would go.
    // For this example, we assume `widget.sample` is populated correctly.
    final sampleToSubmit = widget.sample!;

    try {
      if (_changedImage && _resizedImageBytes != null) {
        // Create a temporary file from bytes for the API call
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/upload.jpg';
        final tempFile = await File(tempPath).writeAsBytes(_resizedImageBytes!);

        // The old API had a separate method for new samples with images.
        // The new API should ideally handle this better, but we'll use the old logic.
        if (widget.status == 'new') {
            // The old API.newSampleWithImage is not in our new ApiClient.
            // This highlights that a full refactor would also involve rethinking the API surface.
            // For now, we'll just show a message.
            toast(context, "Image upload for NEW samples not fully refactored yet.", Colors.orange);
        } else {
            await ref.read(apiClientProvider).updateImage(jwt, sampleID: sampleToSubmit.id!, file: tempFile);
            toast(context, "Image updated!", Colors.green);
        }
        await tempFile.delete();
      }

      // Update the rest of the sample data
      await ref.read(apiClientProvider).updateSample(jwt, sample: sampleToSubmit);

      ref.invalidate(allSamplesProvider);
      ref.invalidate(userSamplesProvider);

      toast(context, "Sample saved successfully!", Colors.green);
      Navigator.of(context).pop();

    } catch (e) {
      toast(context, "An error occurred: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This build method is a simplified placeholder. The original was > 500 lines
    // and would be built here, using the new state variables and methods.
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _fbKey,
          child: Column(
            children: [
              const Text("A simplified placeholder for the very large form."),
              const SizedBox(height: 20),

              // --- UNIFIED IMAGE WIDGETS ---

              _resizedImageBytes != null
                ? Image.memory(_resizedImageBytes!, height: 200)
                : (widget.sample?.imageURL != null && widget.sample!.imageURL!.isNotEmpty)
                  ? Image.network(widget.sample!.imageURL!, height: 200)
                  : Image.asset("assets/images/ncnr.jpg", height: 200),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: const Text("From Gallery"),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: const Text("From Camera"),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              ElevatedButton(onPressed: _submitForm, child: const Text("Submit")),
            ],
          ),
        ),
      ),
    );
  }
}
