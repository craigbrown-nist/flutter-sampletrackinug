import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_samples/Functions/func.dart';
import '../Functions/barcode_scanner_controller.dart';
import 'dart:convert';
import '../API.dart';
import '../models/Sample.dart';
import '../main.dart';
import 'myMoveDialog.dart';
import 'Toast.dart';
//import 'package:flutter/foundation.dart';
//import 'package:code_scanner/code_scanner.dart';

//! Needs to catch 'will pop' scope for android back to also send resulting scans

class ScannerPage extends StatefulWidget {
  const ScannerPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<String> sampleCodes = []; // no type defined
  bool dialVisible = true;
  bool keep =
      false; // need to pass this to the move widget so it does not delete the inherited widget list.

  SpeedDial buildSpeedDial(BuildContext context) {
    final container = MyInheritedWidget.of(context, false);
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.battery_full, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () {
            if (container.toEditSamples.isNotEmpty) {
              for (var i = 0; i < container.toEditSamples.length; i++) {
                container.toEditSamples[i].cellbarcode = "";
                container.toEditSamples[i].sampenvbarcode = "";
                final myFuture = API.updateSample(container.getjwt,
                    sample: container.toEditSamples[i]);
                myFuture.then((response) {
                  if (response != null) {
                    // ignore: use_build_context_synchronously
                    toast(context, "Edited Sample", Colors.green);
                  } else {
                    // ignore: use_build_context_synchronously
                    toast(context, "Error editing sample", Colors.red);
                  }
                });
                container.deleteSamplesToEdit();
                setState(() {
                  sampleCodes = [];
                });
              }
            }
          },
          label: 'Empty cells',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: const Icon(Icons.train, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            if (container.toEditSamples.isNotEmpty) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return MyMoveDialog(keep: keep);
                  });
              setState(() {
                sampleCodes = [];
              });
            }
          },
          label: 'Quick Edit',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final container = MyInheritedWidget.of(context, false);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result)  {
        if (didPop) {
          return;
        }
        debugPrint("here");
        // empty the editing array from preferences
        final container = MyInheritedWidget.of(context, false);
        container.deleteSamplesToEdit();
        //trigger leaving and use own data
        Navigator.pop(context, false);
        //we need to return a future
        //return Future.value(false);
        //return;
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Continuous sample scanning'),
          ),
          body: Column(children: <Widget>[
            Expanded(
                child: FloatingActionButton(
              onPressed: () {
                _awaitReturnVal(context);
              },
              child: const Icon(Icons.camera_alt),
            )),
            Expanded(
              child: Column(
                children: <Widget>[
                  const Text("Result of scan. Tap to delete"),
                  Expanded(
                    child: ListView.separated(
                      itemCount: sampleCodes.length,
                      itemBuilder: (context, index) {
                        return Ink(
                          color: Colors.transparent,
                          child: ListTile(
                            leading:
                                Text(int.parse(sampleCodes[index]).toString()),
                            title: Text(
                                container.toEditSamples[index].sampleName,
                                style: const TextStyle(color: Colors.black)),
                            onTap: () {
                              //delete:
                              setState(() {
                                sampleCodes.removeAt(index);
                                // should be same index for preferences:
                                container.deleteSamplesToEditAtID(index);
                              });
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          color: Colors.black,
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ]),
          floatingActionButton: buildSpeedDial(context)),
    );
  }

  void _awaitReturnVal(BuildContext context) async {
    const single = 0; // i.e. expect a list but it might be just one...
    final dynamic response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const BarcodeScannerWithController(single: single)));

    sampleCodes = sampleCodes + response;

    // add to the active list.
    // Convert List to Set then back to List to remove duplicates
    sampleCodes = [
      ...{...sampleCodes}
    ];

    print('\n');
    print('\n');
    print('\n');
    print('\n');
    print(sampleCodes);
    print('\n');
    print('\n');
    print('\n');
    print('\n');

    // Go and fetch these samples. Should be small so no worries about performance
    // ignore: use_build_context_synchronously
    final container = MyInheritedWidget.of(context, false);
    container.deleteSamplesToEdit();
    // Is it numeric check as this is the ID type for the samples
    // If it is not retrievable remove it from list.
    var j = 0;
    for (var code in sampleCodes) {
      if (!isNumeric(code)) {
        // print("Not in the right format");
        // there was an error getting info from the network:
        // automatically remove sample from list
        // ignore: use_build_context_synchronously
        toast(context, "Not expected code format: $code", Colors.red);
        if (sampleCodes.length > 1) {
          sampleCodes.removeAt(j);
        } else {
          sampleCodes = [];
        }
      }
      j++;
    }

    var i = 0;
    for (var code in sampleCodes) {
      code = (int.parse(code)).toString();
      // Check to see if it is in the database:
      final myFuture = API.getSampleID(code, container.getjwt);
      myFuture.then((response) {
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          Sample sample = Sample.fromJson(jsonResponse[0]);

          if (sample.owner == container.userEmail || container.admin) {
            //add to arrays
            setState(() {
              container.toEditSamples.add(sample);
            });
          } else {
            // print("not your sample");
            // ignore: use_build_context_synchronously
            toast(context, "You don't have access to sample: $code",
                Colors.red);
            if (sampleCodes.length > 1) {
              sampleCodes.removeAt(i);
            } else {
              sampleCodes = [];
            }
          }
          setState(() {
            // print("Setting state");
            if (sampleCodes.isNotEmpty) {
              sampleCodes = sampleCodes;
            } else {
              sampleCodes = [];
            }
          });
        } else {
          print("Bad Network response ");
          // there was an error getting info from the network:
          // automatically remove sample from list
          // ignore: use_build_context_synchronously
          toast(context, "Sample not availble: $code", Colors.red);
          if (sampleCodes.length > 1) {
            sampleCodes.removeAt(i);
          } else {
            sampleCodes = [];
          }
          setState(() {
            // print("Setting state");
            if (sampleCodes.isNotEmpty) {
              sampleCodes = sampleCodes;
            } else {
              sampleCodes = [];
            }
          });
        }
      });

      i++;
    }
  }
}
