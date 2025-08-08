import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWithController extends StatefulWidget {
  const BarcodeScannerWithController({super.key, required this.single});
  final int single;
  // if single = 1 then only scan one element of a barcode
  // if single = 0 then keep scanning until quit....
  @override
  _BarcodeScannerWithControllerState createState() =>
      _BarcodeScannerWithControllerState();
}

class _BarcodeScannerWithControllerState
    extends State<BarcodeScannerWithController>
    with SingleTickerProviderStateMixin {

  List<String> barcodes = [];

  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              MobileScanner(
                controller: controller,
                fit: BoxFit.contain,
                onDetect: (capture) {
                  final List<Barcode> capturedBarcodes = capture.barcodes;
                  if (capturedBarcodes.isEmpty) {
                    return;
                  }

                  final String? rawValue = capturedBarcodes.first.rawValue;
                  if (rawValue == null) {
                    return;
                  }

                  if (widget.single == 1) {
                    Navigator.pop(context, rawValue);
                  } else {
                    setState(() {
                      if (!barcodes.contains(rawValue)) {
                        barcodes.add(rawValue);
                      }
                    });
                  }
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 100,
                  color: Colors.black.withOpacity(0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder<TorchState>(
                          valueListenable: controller.torchState,
                          builder: (context, state, child) {
                            switch (state) {
                              case TorchState.off:
                                return const Icon(Icons.flash_off, color: Colors.grey);
                              case TorchState.on:
                                return const Icon(Icons.flash_on, color: Colors.yellow);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => controller.toggleTorch(),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: controller.isStarting,
                        builder: (context, state, child) {
                          return IconButton(
                            color: Colors.white,
                            icon: state ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
                            iconSize: 32.0,
                            onPressed: () async {
                              if (state) {
                                await controller.stop();
                              } else {
                                await controller.start();
                              }
                            },
                          );
                        },
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder<CameraFacing>(
                          valueListenable: controller.cameraFacingState,
                          builder: (context, state, child) {
                            switch (state) {
                              case CameraFacing.front:
                                return const Icon(Icons.camera_front);
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => controller.switchCamera(),
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.image),
                        iconSize: 32.0,
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            if (await controller.analyzeImage(image.path)) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Barcode found!'), backgroundColor: Colors.green),
                              );
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No barcode found!'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        color: Colors.white,
                        onPressed: () {
                          // Return the list of unique barcodes when exiting
                          Navigator.pop(context, barcodes.toSet().toList());
                        },
                        icon: const Icon(Icons.keyboard_return),
                        iconSize: 32.0,
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
