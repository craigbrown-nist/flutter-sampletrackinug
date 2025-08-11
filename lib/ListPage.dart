// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_samples/models/Forms.dart';
import 'package:flutter_samples/models/Units.dart';
import 'package:flutter_samples/models/User.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// local app files
import 'main.dart';
import 'API.dart';
import 'Functions/func.dart';
import 'Functions/barcode_scanner_controller.dart';
import 'models/Sample.dart';
import 'models/Cells.dart';
import 'UI/NewPage.dart';
import 'UI/Toast.dart';
import 'UI/DetailPage.dart';
import 'UI/adminNavDrawer.dart';
import 'UI/myMoveDialog.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
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

  void _getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String place = prefs.getString('place') ?? "";
    final String location = prefs.getString('location') ?? "";
    final String locationid = prefs.getString('locationid') ?? "";
    final String drawer = prefs.getString('drawer') ?? "";
    if (place != "" && mounted) {
      final container = MyInheritedWidget.of(context, false);
      print(place);
      container.setPlace(place);
      container.setLocation(location);
      container.setLocationid(locationid);
      container.setDrawer(drawer);
    }
  }

  void _getFullCells() {
    if (!mounted) return;
    final container = MyInheritedWidget.of(context, false);
    container.clearFullCells();
    final myFuture = API.getFullCans(container.getjwt);
    myFuture.then((response) {
      if (response.statusCode == 200) {
        var fCells = List<Cells>.empty(growable: true);
        Iterable list = json.decode(response.body);
        fCells = list.map((model) => Cells.fromJson(model)).toList();
        // remove the archived ones:
        if (mounted && container.totalFullCells != fCells.length) {
          // has email list length changed or 1st running?
          container.clearFullCells(); // if so clear the list and repopulate
          for (var i = 0; i < fCells.length; i++) {
            if (fCells[i].archived == "0" && mounted) {
              addToFullCells(context: context, cell: fCells[i]);
            }
          }
        }
      }
    });
  }

  void _getEmptyCells() {
    if (!mounted) return;
    final container = MyInheritedWidget.of(context, false);
    container.clearEmptyCells();
    final myFuture = API.getEmptyCans(container.getjwt);
    myFuture.then((response) {
      if (response.statusCode == 200) {
        var eCells = List<Cells>.empty(growable: true);
        Iterable list = json.decode(response.body);
        eCells = list.map((model) => Cells.fromJson(model)).toList();

        // remove the archived ones:
        if (mounted && container.totalEmptyCells != eCells.length) {
          // has email list length changed or 1st running?
          container.clearEmptyCells(); // if so clear the list and repopulate
          for (var i = 0; i < eCells.length; i++) {
            if (eCells[i].archived == "0" && mounted) {
              addToEmptyCells(context: context, cell: eCells[i]);
            }
          }
        }
      }
    });
  }

  getThisUser() {
    if (!mounted) return;
    final container = MyInheritedWidget.of(context, false);
    var users = List<User>.empty(growable: true);
    /// find user from an email
    final myFuture = API.getUsers(container.getjwt);
    myFuture.then((response) {
      if (response.statusCode == 200) {
        if (!mounted) return;
        var testusers = List<User>.empty(growable: true);
        container.clearUsers();
        container.clearEmails();
        Iterable list = json.decode(response.body);
        testusers = list.map((model) => User.fromJson(model)).toList();
        // remove the archived ones:

         // reorder the testuser list alphabetically
        testusers.sort((a, b) => a.name.toString().compareTo(b.name.toString()));

        for (var i = 0; i < testusers.length; i++) {
          if (testusers[i].name.toString() == "Unknown Name"){
          // move this to the first element in the list
          final User userunknown = testusers.removeAt(i);
          testusers.insert(0, userunknown);

         }
          if (testusers[i].archived == "0") {
            users.add(testusers[i]);
            container.addEmail(testusers[i].email!);
            container.addUserName(testusers[i].name!);
          }
        }

        int index =
            users.indexWhere((users) => users.email == container.userEmail);

        if (index != -1) {
          if (users[index].name != null || users[index].name != "") {
            container.setUser(users[index].name!);
          }
          if (users[index].email != null || users[index].email != "") {
            container.setEmail(users[index].email!);
          }
          if (users[index].manager == "1") {
            container.setAdmin(true);
          } else {
            container.setAdmin(false);
          }
          container.setIndex(index);
        }
      } else {
        // was using this to see if it takes time to login.
        if (flag < 1) { // Changed to < 1 to retry only once
          print('Failed network - trying again');
          getThisUser();
          _getSamples();
          flag = flag + 1;
        }
      }
    });
  }

  /// some helpful initialized values
  bool somthingWrong = true; // probably useless by now - still not removed
  bool textOverScan =
      true; // this is to change what gets seached from the text input or result of a scan
  var singleSample = Sample();

  /// default list for logged in user samples
  var mysamples = List<Sample>.empty(growable: true);

  /// Where we place samples upon (multiple)selection
  var filteredSamples = List<Sample>.empty(growable: true);

  /// new controller for help with search bar and QR codes
  TextEditingController controller = TextEditingController();

  /// help to re-order the sample list by index or chemical name
  bool numlistforward = true;
  bool chemlistforward = true;

  /// Gui items
  String barcoded = "Search";
  bool selectingmode = false;
  bool dialVisible = true;

  @override
  void initState() {
    super.initState();
    _loadDataWhenReady();

    /// set up the search/QR controller
    controller.addListener(() {
      if (!mounted) return;
      if (controller.text.isEmpty) {
        setState(() {
          barcoded = "Search";
          filteredSamples = mysamples;
        });
      } else {
        setState(() {
          barcoded = "";
          filteredSamples = [];
          for (var sample in mysamples) {
            if (sample.sampleId!
                    .toLowerCase()
                    .contains(controller.text.toLowerCase()) ||
                sample.sampleName!
                    .toLowerCase()
                    .contains(controller.text.toLowerCase()) ||
                sample.chemical!
                    .toLowerCase()
                    .contains(controller.text.toLowerCase()) ||
                sample.cellbarcode!
                    .toLowerCase()
                    .contains(controller.text.toLowerCase()) ||
                sample.sampenvbarcode!
                    .toLowerCase()
                    .contains(controller.text.toLowerCase()) ||
                sample.externalUser!
                    .toLowerCase()
                    .contains(controller.text.toLowerCase()) ||
                sample.extraNotes!
                    .toLowerCase()
                    .contains(controller.text.toLowerCase())) {
              filteredSamples.add(sample);
            }
          }
        });
      }
    });
  }

  void _loadDataWhenReady() async {
    // Wait a brief moment to ensure the widget is built and context is available.
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    final container = MyInheritedWidget.of(context, false);

    // Poll until the email is available, with a timeout.
    int attempts = 0;
    while (container.userEmail.isEmpty && attempts < 50) { // Timeout after 5 seconds
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return; // Check again after delay
      attempts++;
    }

    // Check if we timed out or got the email
    if (mounted && container.userEmail.isNotEmpty) {
      print("Email found: ${container.userEmail}. Fetching data.");
      getThisUser();
      _getSamples();
      _getPrefs();
      _getForm();
      _getUnits();
      _getHazards();
      _getFullCells();
      _getEmptyCells();
    } else {
      print("Timed out waiting for user email. Could not load data.");
      if (mounted) {
        toast(context, "Error: Timed out loading user data.", Colors.red);
      }
    }
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  Future _refreshSamples() async {
    _getSamples();
  }

  void _getForm() {
    if (!mounted) return;
    final container = MyInheritedWidget.of(context, false);
    container.clearForm();
    API.getForms(container.getjwt).then((response) {
      if (!mounted) return;
      setState(() {
        if (response.statusCode == 200) {
          Iterable list = json.decode(response.body);
          var forms =
              list.map((model) => FormsOfSample.fromJson(model)).toList();
          for (var p in forms) {
            container.addForm(p.name!);
          }
        } else {
          print('cannot get Forms from server');
        }
      });
    });
  }

  void _getUnits() {
    if (!mounted) return;
    final container = MyInheritedWidget.of(context, false);
    container.clearUnit();
    API.getUnits(container.getjwt).then((response) {
      if (!mounted) return;
      setState(() {
        if (response.statusCode == 200) {
          Iterable list = json.decode(response.body);
          var units =
              list.map((model) => UnitsOfSample.fromJson(model)).toList();
          for (var p in units) {
            container.addUnit(p.name!);
          }
        } else {
          print('cannot get Units from server');
        }
      });
    });
  }

  void _getHazards() {
    if (!mounted) return;
    final container = MyInheritedWidget.of(context, false);
    container.clearHaz();
    API.getHazards(container.getjwt).then((response) {
      if (!mounted) return;
      setState(() {
        if (response.statusCode == 200) {
          container.addHaz("");
          Iterable list = json.decode(response.body);
          var hazards =
              list.map((model) => UnitsOfSample.fromJson(model)).toList();
          for (var p in hazards) {
            container.addHaz(p.name!);
          }
        } else {
          print('cannot get Hazards from server');
        }
      });
    });
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final container = MyInheritedWidget.of(context, false);

    prefs.setString('datauser', "");
    prefs.setBool('isLoggedIn', false);
    prefs.setString('jwt', "");

    container.setJwt('');
    container.setEmail("");
    container.setAdmin(false);
    container.setIndex(-1);
    container.deleteSamplesToEdit();
    container.setUser("");
    container.clearEmails();
    container.clearUsers();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _getSamples() {
    if (!mounted) return;
    final container = MyInheritedWidget.of(context, false);
    final user = container.userEmail;

    if (user.isEmpty) return; // Don't fetch if user email is not set

    API.getUserSamples(user, container.getjwt).then((response) {
      if (!mounted) return;
      setState(() {
        if (response.statusCode == 200) {
          Iterable list = json.decode(response.body);
          var temp = list.map((model) => Sample.fromJson(model)).toList();
          mysamples.clear();
          for (var i = 0; i < temp.length; i++) {
            if (temp[i].archived == "0") {
              mysamples.add(temp[i]);
            }
          }
          filteredSamples = mysamples;
          toast(context, "Received Samples...", Colors.green);

          if (mysamples.isEmpty) {
            toast(context, 'No samples found for this user.', Colors.red);
          }
        } else if (response.statusCode == 401) {
          logout();
        } else {
          toast(context, "Network issues?", Colors.red);
        }

        if (container.admin) {
          Navigator.pushReplacementNamed(context, '/all');
        }
      });
    });
  }

  /// GUI Definition.
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
                    controller: controller,
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
                                          controller.text = "";
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
                                          controller.clear();
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
                            controller.text = response;
                          },
                        ),
                      ]
                    : null,
              ),
            )
          ],
        ));

    final makeBody = RefreshIndicator(
      onRefresh: _refreshSamples,
      child: ListView.builder(
        itemCount: filteredSamples.length,
        itemBuilder: (context, index) {
          return Ink(
            decoration: BoxDecoration(
              border: index == 0
                  ? const Border()
                  : Border(
                      top: BorderSide(
                          width: 1,
                          color: Theme.of(context)
                              .primaryColor)),
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
                  controller.text = "";
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
                    filteredSamples.sort((a, b) => (a.chemical)!
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
        visible: dialVisible,
        curve: Curves.bounceIn,
        children: [
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
                      toast(context, "Edited Sample", Colors.green);
                    } else {
                      toast(context, "Error adding sample", Colors.red);
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
                  print('Moved');
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
                    barcoded = "Select";
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
          SpeedDialChild(
            child: const Icon(Icons.remove_red_eye, color: Colors.white),
            backgroundColor: Colors.blue,
            onTap: () async {
              for (var i = 0; i < filteredSamples.length; i++) {
                if (filteredSamples[i].selected == true) {
                  print('Archiving: doing $i');
                  filteredSamples[i].archived = "1";
                  print('archiving $i');
                  final myFuture = API.updateSample(container.getjwt,
                      sample: filteredSamples[i]);
                  myFuture.then((response) {
                    if (response != null) {
                      print('this one is done archiving $i');
                      toast(context, "Archived Sample", Colors.green);
                    } else {
                      toast(context, "Error archiving sample", Colors.red);
                    }
                  });
                }
              }
              print('Done with list');
              container.toEditSamples.clear();
              _refreshSamples();
            },
            label: 'Archive',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.blue,
          ),
        ],
      );
    }

    return Scaffold(
        drawer: (container.admin)
            ? adminNavDrawer(context)
            : userNavDrawer(context),
        appBar: topAppBar,
        body: makeBody,
        bottomNavigationBar: makeBottom,
        floatingActionButton: (selectingmode)
            ? buildSpeedDial(context)
            : Visibility(
                visible: showPlus == true,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const NewPage(),
                      )),
                )));
  }
}
