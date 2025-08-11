import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:convert';

import '../models/Cells.dart';
import '../main.dart';
import '../API.dart';
import 'CellDetailPage.dart';
import 'myDialog.dart';
import '../Functions/func.dart';

class CellsPage extends StatefulWidget {
  const CellsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CellsPageState createState() => _CellsPageState();
}

class _CellsPageState extends State<CellsPage> {
  var thisList = List<Cells>.empty(growable: true);
  bool isShowFull = true;
  String canStyle = "Van A";
  bool exec = true;

  void _getFullCells() {
    final container = MyInheritedWidget.of(context, false);
    container.clearFullCells();
    final myFuture = API.getFullCans(container.getjwt);
    myFuture.then((response) {
      if (response.statusCode == 200) {
        var fCells = List<Cells>.empty(growable: true);
        Iterable list = json.decode(response.body);
        fCells = list.map((model) => Cells.fromJson(model)).toList();
        // remove the archived ones:

        if (container.totalFullCells != fCells.length) {
          // has email list length changed or 1st running?
          container.clearFullCells(); // if so clear the list and repopulate
          for (var i = 0; i < fCells.length; i++) {
            /// set the descriptions to reasonable values this time.
            // var bc = _fCells[i].barcode;
            // var id = _fCells[i].id;
            // String celltype = GetCellType(bc);
            // // update the cell to the new description
            // final myFuture = API.updateCell(
            //    id: id, barcode: bc, description: celltype);
            // myFuture.then((response) {
            //   if (response == 200) {
            //     print('cell updated');
            //   }
            // });
            // take care with the above as can open too many connections.

            if (fCells[i].archived == "0") {
              // ignore: use_build_context_synchronously
              addToFullCells(context: context, cell: fCells[i]);
              setState(() {
                if (fCells[i].sample?.chemical != '') {
                  if (fCells[i].description == 'Vanadium A') {
                    thisList.add(fCells[i]);
                  }
                }
                //thisList.add(_fCells[i]);
              });
            }
          }
        }
      }
    });
  }

  void _getEmptyCells() {
    final container = MyInheritedWidget.of(context, false);
    container.clearEmptyCells();
    final myFuture = API.getEmptyCans(container.getjwt);
    myFuture.then((response) {
      if (response.statusCode == 200) {
        var eCells = List<Cells>.empty(growable: true);
        Iterable list = json.decode(response.body);
        eCells = list.map((model) => Cells.fromJson(model)).toList();

        // remove the archived ones:

        if (container.totalEmptyCells != eCells.length) {
          // has email list length changed or 1st running?
          container.clearEmptyCells(); // if so clear the list and repopulate
          for (var i = 0; i < eCells.length; i++) {
            // there are some limits on OSX for number of open network files.
            /// set the descriptions to reasonable values this time.
            ///
            // var bc = _eCells[i].barcode;
            // var id = _eCells[i].id;
            // String celltype = GetCellType(bc);
            // // update the cell to the new description
            // final myFuture = API.updateCell(
            //    id: id, barcode: bc, description: celltype);
            // myFuture.then((response) {
            //   if (response == 200) {
            //     print('cell updated');
            //   }
            // });

            if (eCells[i].archived == "0") {
              // ignore: use_build_context_synchronously
              addToEmptyCells(context: context, cell: eCells[i]);
            }
          }
        }
      }
    });
  }

  void updateList() {
    final container = MyInheritedWidget.of(context, false);
    if (isShowFull) {
      if (canStyle == "Van A") {
        thisList = List<Cells>.from(container.fVanAList);
      } else if (canStyle == "Van B") {
        thisList = List<Cells>.from(container.fVanBList);
      } else if (canStyle == "Van C") {
        thisList = List<Cells>.from(container.fVanCList);
      } else if (canStyle == "Van D") {
        thisList = List<Cells>.from(container.fVanDList);
      } else if (canStyle == "Van E") {
        thisList = List<Cells>.from(container.fVanEList);
      } else if (canStyle == "DCS Al") {
        thisList = List<Cells>.from(container.fDCSList);
      } else if (canStyle == "Al 1.2cc") {
        thisList = List<Cells>.from(container.fAl12List);
      } else if (canStyle == "Al 1.6cc") {
        thisList = List<Cells>.from(container.fAl16List);
      } else if (canStyle == "Al 3.1cc") {
        thisList = List<Cells>.from(container.fAl31List);
      } else if (canStyle == "Al 6.3cc") {
        thisList = List<Cells>.from(container.fAl63List);
      } else if (canStyle == "Single Crystal") {
        thisList = List<Cells>.from(container.fSSList);
      } else if (canStyle == "Brookhaven") {
        thisList = List<Cells>.from(container.fBrookhavenEList);
      } else {
        thisList = List<Cells>.from(container.fOtherList);
      }
    } else {
      if (canStyle == "Van A") {
        thisList = List<Cells>.from(container.eVanAList);
      } else if (canStyle == "Van B") {
        thisList = List<Cells>.from(container.eVanBList);
      } else if (canStyle == "Van C") {
        thisList = List<Cells>.from(container.eVanCList);
      } else if (canStyle == "Van D") {
        thisList = List<Cells>.from(container.eVanDList);
      } else if (canStyle == "Van E") {
        thisList = List<Cells>.from(container.eVanEList);
      } else if (canStyle == "DCS Al") {
        thisList = List<Cells>.from(container.eDCSList);
      } else if (canStyle == "Al 1.2cc") {
        thisList = List<Cells>.from(container.eAl12List);
      } else if (canStyle == "Al 1.6cc") {
        thisList = List<Cells>.from(container.eAl16List);
      } else if (canStyle == "Al 3.1cc") {
        thisList = List<Cells>.from(container.eAl31List);
      } else if (canStyle == "Al 6.3cc") {
        thisList = List<Cells>.from(container.eAl63List);
      } else if (canStyle == "Single Crystal") {
        thisList = List<Cells>.from(container.eSSList);
      } else if (canStyle == "Brookhaven") {
        thisList = List<Cells>.from(container.eBrookhavenEList);
      } else {
        thisList = List<Cells>.from(container.eOtherList);
      }
    }
    setState(() {
      thisList = thisList;
    });
  }

  void displayBottomSheet(BuildContext context) {
    //final container = MyInheritedWidget.of(context, false);

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 350.0,
            color: const Color(0xFF737373),
            child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FormBuilder(
                      //context, ///this is the state that we store the form values.
                      //autovalidate: true,
                      initialValue: {
                        'showFull': isShowFull,
                      },

                      child: Column(
                        children: <Widget>[
                          FormBuilderSwitch(
                              title: const Text('Show Full Cells'),
                              name: "showFull",
                              initialValue: isShowFull,
                              decoration: const InputDecoration(
                                icon:
                                    Icon(MdiIcons.testTube, color: Colors.grey),
                              ),
                              onChanged: (value) => setState(() {
                                    isShowFull = (value == true) ? true : false;
                                    updateList();
                                  })),
                          const SizedBox(height: 15),
                          FormBuilderChoiceChip<String>(
                            name: "cans",
                            selectedColor: Colors.blue,
                            onChanged: (value) => setState(() {
                              canStyle = value.toString();
                              updateList();
                            }),
                            initialValue: canStyle,
                            options: const [
                              FormBuilderChipOption(
                                  value: "Van A",
                                  child: Text("Van A")),
                              FormBuilderChipOption(
                                  value: "Van B",
                                  child: Text("Van B")),
                              FormBuilderChipOption(
                                  value: "Van C",
                                  child: Text("Van C")),
                              FormBuilderChipOption(
                                  value: "Van D",
                                  child: Text("Van D")),
                              FormBuilderChipOption(
                                  value: "Van E",
                                  child: Text("Van E")),
                              FormBuilderChipOption(
                                  value: "Al 1.2cc",
                                  child: Text("Al 1.2cc")),
                              FormBuilderChipOption(
                                  value: "Al 1.6cc",
                                  child: Text("Al 1.6cc")),
                              FormBuilderChipOption(
                                  value: "Al 3.1cc",
                                  child: Text("Al 3.1cc")),
                              FormBuilderChipOption(
                                  value: "Al 6.3cc",
                                  child: Text("Al 6.3cc")),
                              FormBuilderChipOption(
                                  value: "DCS Al",
                                  child: Text("DCS Al")),
                              FormBuilderChipOption(
                                  value: "Single Crystal",
                                  child: Text("Single Crystal")),
                              FormBuilderChipOption(
                                  value: "Brookhaven",
                                  child: Text("Brookhaven")),
                              FormBuilderChipOption(
                                  value: "Other",
                                  child: Text("Other")),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                            shape: const StadiumBorder(),
                            elevation: 2,
                            color: Colors.blue,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const MyCellDialog();
                                  });
                              // note this dialog exists and nay further code would be processed.
                              // Not sure how to regenerate the cells lists after this is finished
                            },
                            child: const Text('Create a New Sample Cell/Can'),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //inherited widget!
    final container = MyInheritedWidget.of(context, false);
    if (exec) {
      //set the initial listing.
      setState(() {
        _getFullCells();
        _getEmptyCells();
        updateList();
      });
      thisList = List<Cells>.from(container.fVanAList);
      exec = false;
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cells'),
        ),
        // ignore: avoid_unnecessary_containers
        body: Container(
          child: ListView.builder(
            itemCount: thisList.length,
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
                  color: Colors.transparent,
                ),
                child: ListTile(
                  leading: Text(
                    thisList[index].barcode.toString(),
                  ),
                  title: Text(
                    thisList[index].description.toString(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CellDetailPage(cell: thisList[index])));
                  },
                ),
              );
            },
            // separatorBuilder: (context, index) {
            //   return Divider(
            //     color: Colors.black,
            //   );
            // },
          ),
        ),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: () => displayBottomSheet(context),
            heroTag: null,
            child: const Icon(Icons.arrow_upward),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            onPressed: () {
              _getFullCells();
              Future.delayed(const Duration(seconds: 1));

              _getEmptyCells();
              Future.delayed(const Duration(seconds: 1));
              setState(() {
                Future.delayed(const Duration(seconds: 1));

                updateList();
              });
            },
            heroTag: null,
            child: const Icon(Icons.refresh),
          )
        ]));
  }
}
