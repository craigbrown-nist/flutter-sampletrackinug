import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../Functions/barcode_scanner_controller.dart';
import 'dart:convert';
import '../main.dart';
import '../API.dart';
import '../models/Cells.dart';
import '../Functions/func.dart';
import 'Toast.dart';

class MyCellDialog extends StatefulWidget {
  const MyCellDialog({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyCellDialogState createState() => _MyCellDialogState();
}

class _MyCellDialogState extends State<MyCellDialog> {
  bool exec = true;

  String selected = "";
  String barcode = "";

  @override
  initState() {
    controller.addListener(() {
      if (controller.text.isEmpty) {
        setState(() {
          barcode = "";
        });
      } else {
        barcode = controller.text;
        if (barcode.length >= 5) {
          //check first few values to suggest a drop down
          String celltype = getCellType(barcode);
          setState(() {
            selected = celltype;
          });
        }
      }
    });
    super.initState();
  }

  /// new controller for help with scanning QR codes
  TextEditingController controller = TextEditingController();

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final container = MyInheritedWidget.of(context, false);
    final formKey = GlobalKey<FormState>();

    if (exec) {
      selected = container.cellTypes[4];
      exec = false;
    }

    return AlertDialog(
      content: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.close),
              ),
            ),
          ),
          Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      autocorrect: false,
                      controller: controller,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: barcode,
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: (barcode != "")
                            ? Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 1.0),
                                child: IconButton(
                                    iconSize: 16.0,
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        controller.clear();
                                      });
                                    }),
                              )
                            : Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 1.0),
                                child: IconButton(
                                    iconSize: 16.0,
                                    icon: const Icon(
                                      MdiIcons.qrcodeScan,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      // this probably breaks windows and mac.
                                      try {
                                        const single = 1;
                                        final dynamic response =
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const BarcodeScannerWithController(
                                                            single: single)));
                                        controller.text = response;
                                      } on Exception catch (error) {
                                        print(error);
                                      }
                                    }),
                              ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: selected,
                    items: container.cellTypes
                        .map<DropdownMenuItem<String>>((label) {
                      return DropdownMenuItem<String>(
                        value: label,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selected = value!);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        final myFuture1 = API.addNewCell(container.getjwt,
                            barcode: barcode, description: selected);
                        myFuture1.then((response) {
                          if (response == 200) {
                            // Get the new cell as an object
                            final myFuture =
                                API.getThisCan(barcode, container.getjwt);
                            myFuture.then((response) {
                              if (response.statusCode == 200) {
                                var newCells =
                                    List<Cells>.empty(growable: true);
                                Iterable list = json.decode(response.body);
                                newCells = list
                                    .map((model) => Cells.fromJson(model))
                                    .toList();
                                addToEmptyCells(
                                    // ignore: use_build_context_synchronously
                                    context: context, cell: newCells[0]);
                                // need to add to appropriate list and increment total #
                              }
                            });
                          }
                        });

                        toast(context, "Cell added", Colors.green);

                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child:
                        const Text("Submit", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
