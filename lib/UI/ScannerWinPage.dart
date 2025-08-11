import 'package:flutter/material.dart';
import 'Toast.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'myMoveDialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../main.dart';
import '../API.dart';
import 'dart:convert';
import '../models/Sample.dart';

class ScannerWinPage extends StatefulWidget {
  const ScannerWinPage({super.key});

  @override
  ScannerWinPageState createState() => ScannerWinPageState();
}

class ScannerWinPageState extends State<ScannerWinPage> {
  final _formKey = GlobalKey<FormState>();
  // initialize text field and controller
  String var1 = "";
  TextEditingController textController = TextEditingController();

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
                //sampleCodes = [];
              });
            }
          },
          label: 'Quick Edit',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: const Icon(Icons.remove_red_eye, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () async {
            for (var i = 0; i < container.toEditSamples.length; i++) {
              print('Archiving: doing $i');
              container.toEditSamples[i].archived = "1";
              final myFuture = API.updateSample(container.getjwt,
                  sample: container.toEditSamples[i]);
              myFuture.then((response) {
                if (response != null) {
                  print('this one is done archiving $i');
                  // ignore: use_build_context_synchronously
                  toast(context, "Archived Sample", Colors.green);
                } else {
                  // ignore: use_build_context_synchronously
                  toast(context, "Error archiving sample", Colors.red);
                }
              });
            }
            print('Done with list');
            container.toEditSamples.clear();
          },
          label: 'Archive',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.blue,
        ),
      ],
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  late bool visible;
  String? _barcode;

  @override
  Widget build(BuildContext context) {
    final container = MyInheritedWidget.of(context, false);

    // widget.data data can be either:
    //  "checkOut"
    //     or
    // "checkIn"
    return Scaffold(
        key: _formKey,
        appBar: AppBar(
          title: const Text('Batch scanning'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Manual Entry:',
                      icon: Icon(Icons.keyboard)),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onSubmitted: (text) async {
                    print("manual 1 $text");
                    // add to list and ensure only one occurance:
                    sampleCodes.add(text.toString());
                    sampleCodes = [
                      ...{...sampleCodes}
                    ];
                    print("manual 2 $sampleCodes");
                    // check to remove any null or '' values:
                    sampleCodes.removeWhere((e) => e == '');

                    // make sure all inheritedwidget lists are cleared
                    container.deleteSamplesToEdit();

                    var i = 0;
                    // ignore: avoid_function_literals_in_foreach_calls
                    sampleCodes.forEach((code) async {
                      // Check to see if it is in the database:
                      final response =
                          await API.getSampleID(code, container.getjwt);

                      if (response != '') {
                        print('manual 3 got sample info for $code');
                        final jsonResponse = json.decode(response.body);
                        Sample sample = Sample.fromJson(jsonResponse[0]);

                        if (sample.owner == container.userEmail ||
                            container.admin) {
                          //add to arrays
                          setState(() {
                            print(
                                'Manual 4 : adding sample $code to inherited widget');
                            container.toEditSamples.add(sample);
                            print('manual 5: adding ${sample.sampleId}');
                          });
                        } else {
                          print("manual 6 not your sample");
                          toast(
                              // ignore: use_build_context_synchronously
                              context,
                              "You don't have access to sample: $code",
                              Colors.red);
                          if (sampleCodes.length > 1) {
                            sampleCodes.removeAt(i);
                          } else {
                            sampleCodes = [];
                            container.deleteSamplesToEdit();
                          }
                        }
                      } else {
                        print("manual 7 Bad Network response ");
                        // there was an error getting info from the network:
                        // automatically remove sample from list
                        // ignore: use_build_context_synchronously
                        toast(context, "Sample not availble: $code",
                            Colors.red);
                        if (sampleCodes.length > 1) {
                          sampleCodes.removeAt(
                              i); // does this work if there are samples after i? does using 'code' take care of that?
                        } else {
                          sampleCodes = [];
                          container.deleteSamplesToEdit();
                        }
                      }
                    });

                    i++;

                    setState(() {
                      print("manual 10: setting state barcone to string");
                      _barcode = text.toString();
                      // add to the active list.
                      // Convert List to Set then back to List to remove duplicates
                      if (sampleCodes.isNotEmpty) {
                        print("manual 11: setting state sample codes");
                        sampleCodes = sampleCodes;
                        print("maunal 12: $sampleCodes");
                      } else {
                        print("manual 13: clearing sample codes");
                        sampleCodes = [];
                        container.deleteSamplesToEdit();
                      }
                    });
                    // setState(() {
                    //   _barcode = text.toString();
                    //   // add to the active list.
                    //   // Convert List to Set then back to List to remove duplicates
                    //   if (sampleCodes.length > 0) {
                    //     sampleCodes = sampleCodes;
                    //   } else {
                    //     sampleCodes = [];
                    //   }
                    // });
                  },
                )),
            Center(
                // Add visiblity detector to handle barcode
                // values only when widget is visible
                child: VisibilityDetector(
              onVisibilityChanged: (VisibilityInfo info) {
                visible = info.visibleFraction > 0;
              },
              key: const Key('visible-detector-key'),
              child: BarcodeKeyboardListener(
                  bufferDuration: const Duration(milliseconds: 200),
                  onBarcodeScanned: (barcode) async {
                    WidgetsBinding.instance.focusManager.primaryFocus
                        ?.unfocus();
                    if (!visible) return;
                    sampleCodes.insert(0, barcode);
                    // Check sample and add if possible

                    // check to remove any null or '' values:
                    sampleCodes.removeWhere((e) => e == '');
                    sampleCodes = [
                      ...{...sampleCodes}
                    ];

                    print("In gesture widget");
                    print(sampleCodes);

                    // make sure all inheritedwidget lists are cleared
                    if (barcode.length > 1) {
                      print("Gesture 1 : $barcode");
                      container.deleteSamplesToEdit();

                      var i = 0;
                      // ignore: avoid_function_literals_in_foreach_calls
                      sampleCodes.forEach((code) async {
                        // Check to see if it is in the database:
                        final response =
                            await API.getSampleID(code, container.getjwt);
                        print("Gesture 2: $code");
                        if (response != '') {
                          print("Gesture 3: $code");
                          // print('got sample info for $code');
                          final jsonResponse = json.decode(response.body);
                          Sample sample = Sample.fromJson(jsonResponse[0]);

                          if (sample.owner == container.userEmail ||
                              container.admin) {
                            //add to arrays
                            setState(() {
                              print("Gesture 4: adding to container $code");
                              // print('adding sample $code to inherited widget');
                              container.toEditSamples.add(sample);
                            });
                          } else {
                            print("Gesture 5: Not your sample");
                            print("not your sample");
                            toast(
                                // ignore: use_build_context_synchronously
                                context,
                                "You don't have access to sample: $code",
                                Colors.red);
                            if (sampleCodes.length > 1) {
                              sampleCodes.removeAt(i);
                            } else {
                              sampleCodes = [];
                              container.deleteSamplesToEdit();
                            }
                          }
                        } else {
                          print("Gesture 6: network errir");
                          print("Bad Network response ");
                          // there was an error getting info from the network:
                          // automatically remove sample from list
                          // ignore: use_build_context_synchronously
                          toast(context, "Sample not availble: $code",
                              Colors.red);
                          if (sampleCodes.length > 1) {
                            print("Gesture 7: removing");
                            sampleCodes.removeAt(
                                i); // does this work if there are samples after i? does using 'code' take care of that?
                          } else {
                            print("Gesture 9: clearing");
                            sampleCodes = [];
                            container.deleteSamplesToEdit();
                          }
                          // setState(() {
                          //   if (sampleCodes.length > 0) {
                          //     sampleCodes = sampleCodes;
                          //   } else {
                          //     sampleCodes = [];
                          //   }
                          // });
                        }
                      });

                      i++;

                      setState(() {
                        print("Gesture 10: barcone to string");
                        _barcode = barcode.toString();
                        // add to the active list.
                        // Convert List to Set then back to List to remove duplicates
                        if (sampleCodes.isNotEmpty) {
                          print("Gesture 11: setting state sample codes");
                          sampleCodes = sampleCodes;
                          print(sampleCodes);
                        } else {
                          print("Gesture 12: clearing sample codes");
                          sampleCodes = [];
                          container.deleteSamplesToEdit();
                        }
                      });
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _barcode == null
                            ? 'SCAN BARCODE'
                            : 'BARCODE: $_barcode',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  )),
            )),
            const SizedBox(
              //Use of SizedBox
              height: 30,
            ),
            Expanded(
                child: Column(
              children: <Widget>[
                Text("Result of scan. Tap to delete ${container.toEditSamples.length}"),
                (container.toEditSamples.isNotEmpty)
                    ? Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: container.toEditSamples.length,
                          itemBuilder: (context, index) {
                            return Ink(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: Text((container
                                        .toEditSamples.isNotEmpty)
                                    ? (container.toEditSamples[index].sampleId)
                                        .toString()
                                    : "N/A"),
                                title: Text(
                                    (container.toEditSamples.isNotEmpty)
                                        ? container
                                            .toEditSamples[index].sampleName
                                        : "No sample",
                                    style: const TextStyle(color: Colors.black)),
                                onTap: () {
                                  //delete:
                                  setState(() {
                                    if (sampleCodes.isNotEmpty) {
                                      print("deleting $index");
                                      print(
                                          "deleting $sampleCodes");
                                      print("deleting${container.toEditSamples}");
                                      sampleCodes.removeAt(index);
                                      print("deleted$sampleCodes");

                                      // should be same index for preferences:
                                      container.deleteSamplesToEditAtID(index);
                                      print("deleted${container.toEditSamples}");
                                    } else {
                                      setState(() {
                                        print("42 deleted arrays");
                                        sampleCodes = [];
                                        container.deleteSamplesToEdit();
                                      });
                                    }
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
                      )
                    : const SizedBox(
                        //Use of SizedBox
                        height: 30,
                      ),
              ],
            ))
          ],
        ),
        floatingActionButton: buildSpeedDial(context));
  }
}
