import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../Functions/barcode_scanner_controller.dart';
import 'adminNavDrawer.dart';
import 'DetailPage.dart';
import '../API.dart';
import '../models/Sample.dart';
import 'Toast.dart';
import '../main.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _EmptyPageState createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage> {
  bool somthingWrong = true;
  var samples = List<Sample>.empty(growable: true);
  var mysamples = List<Sample>.empty(growable: true);
  var filteredSamples = List<Sample>.empty(growable: true);

  TextEditingController allcontroller2 = TextEditingController();

  bool numlistforward = true;
  bool chemlistforward = true;
  String barcode = "";
  bool selectingmode = false;
  bool dialVisible = true;

  @override
  initState() {
    _getSamples();
    setState(() {
      filteredSamples = mysamples;
    });

    ///
    /// There is an overflow or something using all the data in the all-list.
    /// Currently it works for all my individual samples - but I dont know where the hard limit is.
    /// Is it the loaded data and just need to wait?
    ///
    allcontroller2.addListener(() {
      if (allcontroller2.text.isEmpty) {
        setState(() {
          barcode = "";
          filteredSamples = mysamples;
        });
      } else {
        setState(() {
          barcode = allcontroller2.text;
          filteredSamples = [];
          //print('Search text: ' + barcode);
          for (var mysamples in mysamples) {
            if (mysamples.sampleId!
                    .toLowerCase()
                    .contains(barcode.toLowerCase()) ||
                mysamples.cellbarcode!
                    .toLowerCase()
                    .contains(barcode.toLowerCase())) {
              // Since we are parsing every change to the 'search text' ensure this is not already in the list?
              filteredSamples.add(mysamples);
            }
          }
        });
      }
    });

    super.initState();
  }

  @override
  dispose() {
    allcontroller2.dispose();
    super.dispose();
  }

  Future _refreshSamples() async {
    // print('trying to refresh');
    _getSamples();
  }

  void _getSamples() {
    final container = MyInheritedWidget.of(context, false);
//    API.getUserSamples(user).then((response) {
    API.getSamples(container.getjwt).then((response) {
      setState(() {
        if (response.statusCode == 200) {
          // print('Network response is good: ' + response.statusCode.toString());
          Iterable list = json.decode(response.body);
          samples = list.map((model) => Sample.fromJson(model)).toList();
          samples.sort((a, b) => a.sampleId!.compareTo(b.sampleId!));
          //samples.removeRange(0,
          //    1); // Note we do this as there seems to be a '00000' in the database
          // now trim the data to only those of the specified user from above

          mysamples = (samples
              .where((sample) => sample.locationid == "Ready to Unload")
              .toList());

          toast(context, 'Getting Samples to Empty', Colors.green);

          somthingWrong = false;
          if (mysamples.isEmpty) {
            somthingWrong = true;
            throw Exception('Failed to get any data: Do you have any samples?');
          }
        } else {
          somthingWrong = true;
          toast(context, 'No samples to empty!', Colors.red);
          throw Exception('Failed to load data: Network issues?');
        }
        filteredSamples = mysamples;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final topAppBar = PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Stack(
          children: <Widget>[
            Container(
              // Background
              color: const Color.fromRGBO(158, 166, 186, 1.0),
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width,
              child: const Center(),
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
                    controller: allcontroller2,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: barcode,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: (barcode != "")
                          ? Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 1.0),
                              child: (selectingmode)
                                  ? IconButton(
                                      icon: const Icon(Icons.cancel),
                                      onPressed: () {
                                        setState(() {
                                          selectingmode = false;
                                          barcode = "";
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
                                          allcontroller2.clear();
                                        });
                                      }),
                            )
                          : null,
                    )),
                actions: (defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.android)
                    ? <Widget>[
                        IconButton(
                            icon: const Icon(
                              MdiIcons.qrcodeScan,
                              color: Colors.blue,
                            ),
                            onPressed: () async {
                              const single = 1;
                              final dynamic response = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BarcodeScannerWithController(
                                              single: single)));
                              setState(() => allcontroller2 = response);
                            }),
                        // if (barcode != "") {
                        //   IconButton(
                        //     icon: Icon(Icons.cancel,color: Color.fromRGBO(158, 166, 186, 1.0),), onPressed:()=> clearSearch(),),
                        // }
                      ]
                    : null,
              ),
            )
          ],
        ));

    // ignore: avoid_unnecessary_containers
    final makeBody = Container(
        child: Stack(
      children: <Widget>[
        RefreshIndicator(
          onRefresh: _refreshSamples,
          child: ListView.separated(
            itemCount: filteredSamples.length,
            itemBuilder: (context, index) {
              return Ink(
                  color: (filteredSamples[index].selected!)
                      ? Colors.blue[200]
                      : Colors.transparent,
                  child: ListTile(
                    leading: Text(
                        (int.parse(filteredSamples[index].sampleId!.toString()))
                            .toString()),
                    title: Text(filteredSamples[index].chemical.toString(),
                        style: (filteredSamples[index].haz1 == "" ||
                                filteredSamples[index].haz1 != null)
                            ? const TextStyle(color: Colors.red)
                            : const TextStyle(color: Colors.black)),
                    trailing: (selectingmode)
                        ? ((filteredSamples[index].selected)!)
                            ? const Icon(Icons.check_box)
                            : const Icon(Icons.check_box_outline_blank)
                        : const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      setState(() {
                        if (selectingmode) {
                          filteredSamples[index].selected =
                              !filteredSamples[index].selected!;
                          // print("sample ID: " +
                          //     filteredSamples[index].sampleId.toString());
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                      sample: filteredSamples[index])));
                        }
                      });
                      // FocusScopeNode currentFocus = FocusScope.of(context);
                      // if (!currentFocus.hasPrimaryFocus) {
                      //   currentFocus.unfocus();
                      // }
                    },
                    onLongPress: () {
                      setState(() {
                        selectingmode = true;
                        allcontroller2.text = "";
                        barcode = "Cancel multiselect ->";
                        filteredSamples[index].selected =
                            !filteredSamples[index].selected!;
                      });
                    },
                    selected: filteredSamples[index].selected!,
                  ));
            },
            separatorBuilder: (context, index) {
              return const Divider(
                color: Colors.black,
              );
            },
          ),
        ),
      ],
    ));

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

    return Scaffold(
      drawer: adminNavDrawer(context),
      appBar: topAppBar,
      body: makeBody,
      bottomNavigationBar: makeBottom,
      floatingActionButton: FloatingActionButton(
          child: const Icon(MdiIcons.flaskEmptyMinus),
          onPressed: () {
            //check if
            final container = MyInheritedWidget.of(context, false);
            for (var p in filteredSamples) {
              if (p.selected == true) {
                // // (1) tell database the cell is free
                // if (p.cellbarcode != "" ||
                //     p.cellbarcode != " " ||
                //     p.cellbarcode != null) {
                //   final myFuture = API.getThisCan(p.cellbarcode);
                //   myFuture.then((response) {
                //     if (response.statusCode == 200) {
                //       try {
                //         Map<String, dynamic> list = json.decode(response.body);
                //         // can is in the database
                //         print(list[0].toString());
                //       } on Error {
                //         // A few things have/can be wrong if here.
                //         // 1 there is no ID for this cell
                //         // 2 The cell is not in the database.
                //         //  so lets add it.
                //         if (p.cellbarcode.toString() != "" ||
                //             p.cellbarcode != null) {
                //           //determine what type of cell:
                //           var bc = p.cellbarcode;
                //           String celltype = GetCellType(bc);
                //           final myFuture1 = API.addNewCell(
                //               barcode: bc, description: celltype);
                //           myFuture1.then((response) {
                //             if (response == 200) {
                //               print('cell added');
                //             }
                //           });
                //         }
                //       }
                //     }
                //   });
                // }

                // (2) move the sample to Decision needed
                // print("Moving sample to Lab/B-147/decision needed");
                if (p.place != "Lab") {
                  p.place = "Lab";
                }
                if (p.place != "B147") {
                  p.place = "B147";
                }
                if (p.place != "Decision needed") {
                  p.place = "Decision needed";
                }
                if (p.place != "Drawer") {
                  p.place = "";
                }

                // (3) ensure sample and environment is blank
                p.cellbarcode = "";
                p.sampenvbarcode = "";
                p.parent = "0";
                p.date =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

                //update
                final myFuture = API.updateSample(container.getjwt, sample: p);
                // print(p.sampleId);
                myFuture.then((response) {
                  if (response != null) {
                    print('sample updated');
                  }
                });
              }
            }
            // remove selected items from list.
            filteredSamples.removeWhere((sample) => sample.selected == true);

            setState(() {
              allcontroller2.clear();
              selectingmode = false;
              barcode = "";
            });

            toast(context, "Samples Emptied!", Colors.green);
          }),
    );
  }
}
