import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWithController extends StatefulWidget {
  const BarcodeScannerWithController({super.key, required this.single});
  final int single;
  // if single = 1 then only scan one element of a barcode
  // if single = 0 then keep scanning until quit....
  @override
  // ignore: library_private_types_in_public_api
  _BarcodeScannerWithControllerState createState() =>
      _BarcodeScannerWithControllerState();
}

class _BarcodeScannerWithControllerState
    extends State<BarcodeScannerWithController>
    with SingleTickerProviderStateMixin {
  String?
      barcode; // return this if Single = 1 it could be an integer (sample) or a string (cell) - deal with it in the calling function
  List<String>?
      barcodes; // return this if Single = 0 - it will always be a sample barcode i.e. an integer

  MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    // formats: [BarcodeFormat.qrCode]
    // facing: CameraFacing.front,
  );

  bool isStarted = true;

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
                // allowDuplicates: true,
                // controller: MobileScannerController(
                //   torchEnabled: true,
                //   facing: CameraFacing.front,
                // ),
                onDetect: (barcode, args) {
                  if (widget.single == 1) {
                    setState(() {
                      this.barcode = barcode.rawValue;
                      Navigator.pop(context, barcode.rawValue);
                      // Once complete lets go back to the calling page.
                    });
                  } else {
                    barcodes!.add((barcode.rawValue.toString()));
                  }
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 100,
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder(
                          valueListenable: controller.torchState,
                          builder: (context, state, child) {
                            // ignore: unnecessary_null_comparison
                            if (state == null) {
                              return const Icon(
                                Icons.flash_off,
                                color: Colors.grey,
                              );
                            }
                            // ignore: unnecessary_cast
                            switch (state as TorchState) {
                              case TorchState.off:
                                return const Icon(
                                  Icons.flash_off,
                                  color: Colors.grey,
                                );
                              case TorchState.on:
                                return const Icon(
                                  Icons.flash_on,
                                  color: Colors.yellow,
                                );
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => controller.toggleTorch(),
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: isStarted
                            ? const Icon(Icons.stop)
                            : const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                        onPressed: () => setState(() {
                          isStarted ? controller.stop() : controller.start();
                          isStarted = !isStarted;
                        }),
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 200,
                          height: 50,
                          child: FittedBox(
                            child: Text(
                              barcode ?? 'looking for QR',
                              overflow: TextOverflow.fade,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // IconButton(
                      //   color: Colors.white,
                      //   icon: ValueListenableBuilder(
                      //     valueListenable: controller.cameraFacingState,
                      //     builder: (context, state, child) {
                      //       if (state == null) {
                      //         return const Icon(Icons.camera_front);
                      //       }
                      //       switch (state as CameraFacing) {
                      //         case CameraFacing.front:
                      //           return const Icon(Icons.camera_front);
                      //         case CameraFacing.back:
                      //           return const Icon(Icons.camera_rear);
                      //       }
                      //     },
                      //   ),
                      //   iconSize: 32.0,
                      //   onPressed: () => controller.switchCamera(),
                      // ),
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.image),
                        iconSize: 32.0,
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            if (await controller.analyzeImage(image.path)) {
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Barcode found!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No barcode found!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            if (widget.single == 0) {
                              //COMMENT OUT THIS TEST !!!!
                              //barcodes = ['123', '124', '123', '124', '126'];
                              // COMMENT OUT ABOVE!
                              Navigator.pop(context, barcodes);
                            } else {
                              Navigator.pop(context, '');
                            }
                            // Once complete lets go back to the calling page.
                          });
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
