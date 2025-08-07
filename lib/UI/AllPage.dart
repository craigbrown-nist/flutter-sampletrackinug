import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:convert';
import 'dart:async';
//import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../Functions/barcode_scanner_controller.dart';
import '../main.dart';
import '../API.dart';
import '../models/Sample.dart';
import 'DetailPage.dart';
import '../UI/adminNavDrawer.dart';
import '../UI/myMoveDialog.dart';
import '../UI/Toast.dart';
import 'NewPage.dart';


class AllPage extends StatefulWidget {
  const AllPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AllPageState createState() => _AllPageState();
}

class _AllPageState extends State<AllPage> {
  String qr = "";
  late Offset position;
  Set<String> listQr = {};

  // List<Barcode> barcodes = [];
  OverlayEntry? overlayEntry;
  OverlayEntry? overlayEntryButtons;

  int flag = 0;
  int textFlag = 0;
  // use this to control visibility of FAB + sample button
  bool showPlus = true;

  bool somthingWrong = true;
  var samples = List<Sample>.empty(growable: true);
  var mysamples = List<Sample>.empty(growable: true);
  var filteredSamples = List<Sample>.empty(growable: true);

  TextEditingController allcontroller = TextEditingController();

  bool textOverScan =
      true; // this is to change what gets seached from the text input or result of a scan

  bool numlistforward = true;
  bool chemlistforward = true;
  String barcoded = "";
  bool selectingmode = false;
  bool dialVisible = true;

  @override
  initState() {
    super.initState();

    _getSamples();

    setState(() {
      filteredSamples = mysamples;
    });

    allcontroller.addListener(() {
      if (allcontroller.text.isEmpty) {
        setState(() {
          barcoded = "";
          filteredSamples = mysamples;
          filteredSamples.sort((a, b) => a.sampleId!.compareTo(b.sampleId!));
          var reversedList = filteredSamples.reversed.toList();
          filteredSamples = reversedList;
          numlistforward = false;
        });
      } else {
        setState(() {
          barcoded = allcontroller.text;
          filteredSamples = [];

          //print('Search text: ' + barcode);
          for (var mysamples in mysamples) {
            if (mysamples.sampleId!
                    .toLowerCase()
                    .contains(barcoded.toLowerCase()) ||
                mysamples.sampleName!
                    .toLowerCase()
                    .contains(barcoded.toLowerCase()) ||
                mysamples.chemical!
                    .toLowerCase()
                    .contains(barcoded.toLowerCase()) ||
                mysamples.cellbarcode!
                    .toLowerCase()
                    .contains(barcoded.toLowerCase()) ||
                mysamples.sampenvbarcode!
                    .toLowerCase()
                    .contains(barcoded.toLowerCase()) ||
                mysamples.externalUser!
                    .toLowerCase()
                    .contains(barcoded.toLowerCase()) ||
                mysamples.locationString!
                    .toLowerCase()
                    .contains(barcoded.toLowerCase()) ||
                mysamples.owner!.contains(barcoded) ||
                mysamples.userName!.contains(barcoded) ||
                mysamples.extraNotes!
                    .toLowerCase()
                    .contains(barcoded.toLowerCase())) {
              // print('Matching sample id: ' + mysamples.sampleId);
              // Since we are parsing every change to the 'search text' ensure this is not already in the list?
              filteredSamples.add(mysamples);
              filteredSamples
                  .sort((a, b) => a.sampleId!.compareTo(b.sampleId!));
              var reversedList = filteredSamples.reversed.toList();
              filteredSamples = reversedList;
              numlistforward = false;
            }
          }
        });
      }
    });
  }

  @override
  dispose() {
    allcontroller.dispose();
    super.dispose();
  }

  Future _refreshSamples() async {
    print('trying to refresh');
    _getSamples();
    setState(() {
      filteredSamples = mysamples;
      filteredSamples.sort((a, b) => a.sampleId!.compareTo(b.sampleId!));
      var reversedList = filteredSamples.reversed.toList();
      filteredSamples = reversedList;
      numlistforward = false;
    });
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    final container = MyInheritedWidget.of(context, false);

    //print(prefs.getString('jwt'));
    prefs.setString('datauser', "");
    prefs.setBool('isLoggedIn', false);
    prefs.setString('jwt', "");
    //print('resetting preferences');
    //print(prefs.getString('jwt'));

    container.setJwt('');
    container.setEmail("");
    container.setAdmin(false);
    container.setIndex(-1);
    container.deleteSamplesToEdit();
    container.setUser("");
    container.clearEmails();
    container.clearUsers();

    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/');
  }

  void _getSamples() {
    final container = MyInheritedWidget.of(context, false);
//    API.getUserSamples(user).then((response) {
    API.getSamples(container.getjwt).then((response) {
      setState(() {
        if (response.statusCode == 200) {
          //print('Network response is good: ' + response.statusCode.toString());
          Iterable list = json.decode(response.body);
          samples = list.map((model) => Sample.fromJson(model)).toList();
          samples.sort((a, b) => a.sampleId!.compareTo(b.sampleId!));
          // Note we do this as there seems to be a '00000' in the database
          // now trim the data to only those of the specified user from above
          mysamples = samples;
          filteredSamples = samples;
          filteredSamples.sort((a, b) => a.sampleId!.compareTo(b.sampleId!));
          var reversedList = filteredSamples.reversed.toList();
          filteredSamples = reversedList;
          numlistforward = false;
          toast(context, "Recieved Samples ...", Colors.green);

          somthingWrong = false;
          if (mysamples.isEmpty) {
            somthingWrong = true;
            throw Exception(
                'Failed to get any data for user: Do you have any samples?');
          }
        } else if (response.statusCode == 401) {
          // There is a permission issue: assume JWT expired and logout
          logout();
        } else {
          somthingWrong = true;
          throw Exception('Failed to load data: Network issues?');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final container = MyInheritedWidget.of(context, false);

    final topAppBar = PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Stack(
          children: <Widget>[
            Container(
              // Background
              color: const Color.fromRGBO(158, 166, 186, 1.0),
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width,
            ),

            Container(), // Required some widget in between to float AppBar

            Positioned(
              // To take AppBar Size only
              top: 30,
              left: 20.0,
              right: 20.0,
              child: AppBar(
                elevation: 0.1,
                iconTheme: const IconThemeData(
                    color: Color.fromRGBO(158, 166, 186, 1.0)),
                backgroundColor: Colors.white,
                primary: false,
                title: TextField(
                    autocorrect: false,
                    controller: allcontroller,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: barcoded,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: (Icons.qr_code.toString() != "")
                          ? Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 1.0),
                              child: (selectingmode)
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel),
                                      onPressed: () {
                                        setState(() {
                                          selectingmode = false;
                                          allcontroller.text = "";
                                          for (var p in filteredSamples) {
                                            p.selected = false;
                                          }
                                        });
                                      },
                                    )
                                  : IconButton(
                                      iconSize: 16.0,
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          filteredSamples = mysamples;
                                          filteredSamples.sort((a, b) => a
                                              .sampleId!
                                              .compareTo(b.sampleId!));
                                          var reversedList =
                                              filteredSamples.reversed.toList();
                                          filteredSamples = reversedList;
                                          numlistforward = false;
                                          allcontroller.clear();
                                        });
                                      }),
                            )
                          : null,
                    )),
                actions: (defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.android)
                    ? <Widget>[
                        IconButton(
                          icon: (defaultTargetPlatform == TargetPlatform.iOS ||
                                  defaultTargetPlatform ==
                                      TargetPlatform.android)
                              ? const Icon(
                                  MdiIcons.qrcodeScan,
                                  color: Colors.blue,
                                )
                              : const Icon(MdiIcons.heartBroken),
                          onPressed: () async {
                            const int single = 1;
                            final dynamic response = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BarcodeScannerWithController(
                                            single: single)));
                            allcontroller.text = response;
                          },
                        ),
                      ]
                    : null,
              ),
            )
          ],
        ));

    // ignore: avoid_unnecessary_containers
    final makeBody = Container(
      child: RefreshIndicator(
        onRefresh: _refreshSamples,
        child: ListView.builder(
          itemCount: filteredSamples.length,
          itemBuilder: (context, index) {
            return Ink(
              decoration: BoxDecoration(
                border: index == 0
                    ? const Border() // This will create no border for the first item
                    : Border(
                        top: BorderSide(
                            width: 1,
                            color: Theme.of(context)
                                .primaryColor)), // This will create top borders for the rest
                color: filteredSamples[index].selected!
                    ? Colors.blue[200]
                    : Colors.transparent,
              ),
              child: ListTile(
                leading: Text(
                    (int.parse(filteredSamples[index].sampleId!)).toString(),
                    style: (filteredSamples[index].archived != "0")
                        ? const TextStyle(color: Colors.green)
                        : const TextStyle(color: Colors.black)),
                title: Text(filteredSamples[index].chemical!,
                    style: (filteredSamples[index].haz1 == "" ||
                            filteredSamples[index].haz1 != null)
                        ? const TextStyle(color: Colors.red)
                        : const TextStyle(color: Colors.black)),
                trailing: (selectingmode)
                    ? ((filteredSamples[index].selected!)
                        ? const Icon(Icons.check_box)
                        : const Icon(Icons.check_box_outline_blank))
                    : const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  setState(() {
                    if (selectingmode) {
                      filteredSamples[index].selected =
                          !filteredSamples[index].selected!;
                      // print("sample ID: " +
                      // filteredSamples[index].sampleId.toString());
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(sample: filteredSamples[index])));
                    }
                  });
                },
                onLongPress: () {
                  setState(() {
                    selectingmode = true;
                    barcoded = "Cancel multiselect ->";
                    filteredSamples[index].selected =
                        !filteredSamples[index].selected!;
                  });
                },
                selected: filteredSamples[index].selected!,
              ),
            );
          },
        ),
      ),
    );

    final makeBottom = SizedBox(
      height: 55.0,
      child: BottomAppBar(
        color: const Color.fromRGBO(158, 166, 186, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(MdiIcons.orderNumericDescending, color: Colors.white),
              // Here we can reorder the lists
              onPressed: () {
                setState(() {
                  if (numlistforward == false) {
                    filteredSamples
                        .sort((a, b) => a.sampleId!.compareTo(b.sampleId!));
                    numlistforward = true;
                  } else {
                    filteredSamples
                        .sort((a, b) => a.sampleId!.compareTo(b.sampleId!));
                    var reversedList = filteredSamples.reversed.toList();
                    filteredSamples = reversedList;
                    numlistforward = false;
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(MdiIcons.orderAlphabeticalDescending,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  if (chemlistforward == false) {
                    filteredSamples.sort((a, b) => (a.chemical!)
                        .toLowerCase()
                        .compareTo(b.chemical!.toLowerCase()));
                    chemlistforward = true;
                  } else {
                    filteredSamples.sort((a, b) => (a.chemical!)
                        .toLowerCase()
                        .compareTo(b.chemical!.toLowerCase()));
                    var reversedList = filteredSamples.reversed.toList();
                    filteredSamples = reversedList;
                    chemlistforward = false;
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(MdiIcons.recycle, color: Colors.white),
              onPressed: () {
                setState(() {
                  _refreshSamples();
                });
              },
            ),
          ],
        ),
      ),
    );

    SpeedDial buildSpeedDial(BuildContext context) {
      return SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: const IconThemeData(size: 22.0),
        // child: Icon(Icons.add),
        visible: dialVisible,
        curve: Curves.bounceIn,
        children: [
            SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.blue,
onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const NewPage(),
                      )),label: 'Add',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.blueAccent,
                      
          ),
          SpeedDialChild(
            child: const Icon(Icons.battery_full, color: Colors.white),
            backgroundColor: Colors.deepOrange,
            onTap: () {
              for (var i = 0; i < filteredSamples.length; i++) {
                if (filteredSamples[i].selected == true) {
                  filteredSamples[i].cellbarcode = "";
                  filteredSamples[i].sampenvbarcode = "";
                  final myFuture = API.updateSample(container.getjwt,
                      sample: filteredSamples[i]);
                  myFuture.then((response) {
                    if (response != null) {
                      // ignore: use_build_context_synchronously
                      toast(context, "Edited Sample", Colors.green);
                    } else {
                      // ignore: use_build_context_synchronously
                      toast(context, "Error editing sample", Colors.red);
                    }
                  });
                  container.toEditSamples.clear();
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
            onTap: () async {
              for (var i = 0; i < filteredSamples.length; i++) {
                if (filteredSamples[i].selected == true) {
                  container.addSamplesToEdit(filteredSamples[i]);
                }
              }
              await showDialog(
                  context: context,
                  builder: (context) {
                    return const MyMoveDialog(keep: false);
                  }).then((val) {
                if (val == 'Moved') {
                  setState(() {
                    selectingmode = false;
                    barcoded = "";
                    for (var p in filteredSamples) {
                      p.selected = false;
                    }
                  });
                  _refreshSamples();
                }
              });
            },
            label: 'Move',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.green,
          ),
        
        ],
      );
    }

    return Scaffold(
      drawer: adminNavDrawer(context),
      appBar: topAppBar,
      body: makeBody,
      bottomNavigationBar: makeBottom,
      floatingActionButton: buildSpeedDial(context),
    );
  }
}
