import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../Functions/barcode_scanner_controller.dart';
import '../models/Sample.dart';
import '../main.dart';
import '../API.dart';
import 'Toast.dart';
import 'data.dart';

///This could be StatelessWidget but it won't work on Dialogs for now until this issue is fixed: https://github.com/flutter/flutter/issues/45839
/// I think I prefer the stateful widget: I need to call values anyway.

class MoveContent extends StatefulWidget {
  /// passed in values
  /// Need to check if these are set-if not dafault to empty new sample, and status = new

  final Sample sample;
  final String status;

  const MoveContent({super.key, required this.sample, required this.status});

  /// @override is not neccesary, but indicates we want to do this purposefully
  @override
  // ignore: library_private_types_in_public_api
  _MoveContentState createState() => _MoveContentState();
}

class _MoveContentState extends State<MoveContent> {
  /// need a class for the focusnode to operate between each widget.
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();
  final FocusNode _nodeText5 = FocusNode();
  final FocusNode _nodeText6 = FocusNode();

  /// Creates the [KeyboardActionsConfig] to hook up the fields
  /// and their focus nodes to our [FormKeyboardActions].
  /// Wish there was a way to loop over nodes and simplify. This is just boiler plate.
  ///
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
        KeyboardActionsItem(focusNode: _nodeText2, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
        KeyboardActionsItem(focusNode: _nodeText3, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
        KeyboardActionsItem(focusNode: _nodeText4, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
        KeyboardActionsItem(focusNode: _nodeText5, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
        KeyboardActionsItem(focusNode: _nodeText6, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
      ],
    );
  }

  String selectedPlace = "";
  String location = "";
  List locationList = [];
  String locationid = "";
  List locationidList = [];
  String drawer = "";
  List drawerList = [];
  bool _arch = false; // init bool for archived or not
  bool exec =
      true; // this is just to set the values to default to the sample values once on widget build
  String cellbarcode = '';
  String sampenvbarcode = '';

  final textControllerCell = TextEditingController();
  final textControllerSE = TextEditingController();

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    /// i.e. execute once to set radio button units based on input sample or simple defaults.
    /// Will throw an error accessing widget.sample if it is empty!
    if (exec) {
      //var pp = true;
      //widget.sample.place = "GuideHall";
      //widget.sample.location = "North";
      //widget.sample.locationid = "Bank 20";
      //widget.sample.drawer = "2";

      _arch = (widget.sample.archived == "0" || widget.sample.archived == null)
          ? false
          : true;
      selectedPlace =
          ((widget.sample.place != "") ? widget.sample.place : "Confinement")!;

      cellbarcode = ((widget.sample.cellbarcode == "" ||
              widget.sample.cellbarcode == null)
          ? ""
          : widget.sample.cellbarcode)!;
      sampenvbarcode = ((widget.sample.sampenvbarcode == "" ||
              widget.sample.sampenvbarcode == null)
          ? ""
          : widget.sample.sampenvbarcode)!;

      // get values for next list
      if (selectedPlace == "") {
        selectedPlace = "Confinement";
      }

      if (selectedPlace == 'Confinement') {
        locationList = locationOptionsConf;
      } else if (selectedPlace == 'GuideHall') {
        locationList = locationOptionsGuide;
      } else if (selectedPlace == 'Lab') {
        locationList = locationOptionsLab;
      } else {
        locationList = locationOptionsOther;
      }

      location =
          ((widget.sample.location != "" || widget.sample.location != " ")
              ? widget.sample.location
              : "")!;
      // get values for next list
      if (location == 'BT1') {
        locationidList = bt1locid;
      } else if (location == 'BT2') {
        locationidList = bt2locid;
      } else if (location == 'BT4') {
        locationidList = bt4locid;
      } else if (location == 'BT5') {
        locationidList = bt5locid;
      } else if (location == 'BT7') {
        locationidList = bt7locid;
      } else if (location == 'BT8') {
        locationidList = bt8locid;
      } else if (location == 'MACS') {
        locationidList = macslocid;
      } else if (location == 'East') {
        locationidList = guideEASTlocid;
      } else if (location == 'North') {
        locationidList = guideNORTHlocid;
      } else if (location == 'SPINS') {
        locationidList = guideSPINSlocid;
      } else if (location == 'Polar') {
        locationidList = guidePOLARlocid;
      } else if (location == 'A115') {
        locationidList = a115locid;
      } else if (location == 'A117') {
        locationidList = a117locid;
      } else if (location == 'A127') {
        locationidList = a127locid;
      } else if (location == 'A132') {
        locationidList = a132locid;
      } else if (location == 'B147') {
        locationidList = b147locid;
      } else if (location == 'B142') {
        locationidList = b142locid;
      } else if (location == 'E131') {
        locationidList = e131locid;
      } else if (location == 'E133') {
        locationidList = e133locid;
      } else if (location == 'E132') {
        locationidList = e132locid;
      } else if (location == 'E134') {
        locationidList = e134locid;
      } else if (location == 'E135') {
        locationidList = e135locid;
      } else if (location == 'E136') {
        locationidList = e136locid;
      } else if (location == 'E137') {
        locationidList = e137locid;
      } else if (location == 'E138') {
        locationidList = e138locid;
      } else if (location == 'HP_Clear') {
        locationidList = hplocid;
      } else if (location == 'Shipped back') {
        locationidList = shiplocid;
      } else if (location == 'Waste') {
        locationidList = [""];
      } else {
        locationidList = guideINSTlocid;
      }

      locationid =
          ((widget.sample.locationid != "" && widget.sample.locationid != null)
              ? widget.sample.locationid
              : "")!;
      // get values for next list
      if (locationid == 'Black Cab') {
        drawerList = cabinetdrawer;
      } else if (locationid == 'Beige Cab') {
        drawerList = cabinetdrawer;
      } else if (locationid == 'Grey Cab') {
        drawerList = cabinetdrawer;
      } else if (locationid == 'Cream Cab') {
        drawerList = otherdrawer;
      } else if (locationid == 'Cabinet') {
        drawerList = otherdrawer;
      } else if (locationid == 'Bank 2') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 13') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 14') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 15') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 16a') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 16') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 18') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 19') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 17') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 4') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 7') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 20') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 21') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 22') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 23') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 24') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 25') {
        drawerList = bankdrawer;
      } else if (locationid == 'Bank 26') {
        drawerList = bankdrawer;
      } else if (locationid == 'Freezer') {
        drawerList = drawer5;
      } else if (locationid == 'Argon box') {
        drawerList = drawer4;
      } else if (locationid == 'Freezer4-Left') {
        drawerList = drawer4;
      } else if (locationid == 'Freezer4-Right') {
        drawerList = drawer4;
      } else if (locationid == 'Fridge-Left') {
        drawerList = drawer6;
      } else if (locationid == 'Fridge-Right') {
        drawerList = drawer6;
      } else {
        drawerList = [];
      }
      drawer = ((widget.sample.drawer != "" && widget.sample.location != null)
          ? widget.sample.drawer
          : "")!;
      exec = false;
    }

    return KeyboardActions(
      /// This is a PITA and should not be needed
      /// because the IOS keyboard is terrible in flutter.
      ///     Cannot have decimals,
      ///     No cancel/done buttons etc
      ///
      ///  Side effect is that flutter buildforms is inconstent.
      ///  Not a big deal as we can call the values of those widgets on submit,
      ///  and place in the state for convenient JSON extraction.
      ///  And we do not really need to revert any values to inital the way we are using the APP.
      ///
      config: _buildConfig(context),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FormBuilder(
                /// context, this is the state that we store the form values.
                key: _fbKey,

                /// might implement later:
                //autovalidateMode: true,

                /// the JSON command ot the server now looks like this:
                ///
                // {
                //     "sample_name": "NaYbO2",
                //     "chemical": "Sodium Ytterbium oxide",
                //     "owner": "Craig Brown",
                //     "location": "BT1",
                //     "quantity": "5",
                //     "units": "g",
                //     "cellbarcode": "VB000001",
                //     "sampenvbarcode": "",
                //     "archived": "FALSE",
                //     "parent": "",                      // not used now
                //     "added": "2018-05-21 09:47:13",
                //     "form": "Powder",
                //     "date": "2018-5-21",               // do we need this?
                //     "external_user": "",
                //     "extra_notes": "",
                //     "sample_id": "999",
                //     "ip": "129.6.218.228",             // this is autorecorded
                //     "place": "Instrument",
                //     "locationid": "On Beam",
                //     "username": "waitingfor.cmb@gmail.com",
                //     "hazards": [
                //         {
                //             "hazard": "H2O sensitive"
                //         }
                //     ]
                // }'

                initialValue: {
                  'chemical': widget.sample.chemical,
                  'sample_name': widget.sample.sampleName,
                  'external_user': widget.sample.externalUser,
                  'cellbarcode': widget.sample.cellbarcode,
                  'sampenvbarcode': widget.sample.sampenvbarcode,
                  'extra_notes': widget.sample.extraNotes,
                  'archived': widget.sample.archived,
                  'place': selectedPlace,
                  'location': location,
                  'locationID': locationid,
                  'drawer': drawer,
                  // 'Day': "",
                  // 'Month': "",
                  // 'Year': "",
                  // 'Surname': "",
                  //'Name': "",
                  //'Username': "",
                },

                /// This is where the widget tree starts being built
                ///
                child: Column(
                  children: <Widget>[
                    FormBuilderField(
                      name: "name",
                      builder: (FormFieldState<dynamic> field) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Select option",
                            contentPadding:
                                const EdgeInsets.only(top: 10.0, bottom: 0.0),
                            border: InputBorder.none,
                            errorText: field.errorText,
                          ),
                          child: Container(),
                        );
                      },
                    ),

                    FormBuilderTextField(
                      keyboardType: TextInputType.text,
                      focusNode: _nodeText1,
                      name: "chemical",
                      onSaved: (value) {
                        widget.sample.chemical = value;
                      },
                      decoration: const InputDecoration(
                        labelText: "Chemical Name (for OSHE)",
                        icon: Icon(MdiIcons.vote),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.maxWordsCount(70),
                      ]),
                    ),
                    FormBuilderTextField(
                      keyboardType: TextInputType.text,
                      focusNode: _nodeText2,
                      name: "sample_name",
                      onSaved: (value) {
                        widget.sample.sampleName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: "Sample Name (Your identifier)",
                        icon: Icon(MdiIcons.voteOutline),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.maxWordsCount(70),
                      ]),
                    ),
                    FormBuilderTextField(
                      keyboardType: TextInputType.text,
                      focusNode: _nodeText3,
                      name: "external_user",
                      onSaved: (value) {
                        widget.sample.externalUser = value;
                      },
                      decoration: const InputDecoration(
                        labelText: "External User",
                        icon: Icon(Icons.child_friendly),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.maxWordsCount(70),
                      ]),
                    ),

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: IconButton(
                              icon: const Icon(
                                MdiIcons.qrcodeScan,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                const int single = 1;
                                final dynamic response = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BarcodeScannerWithController(
                                                single: single)));
                                textControllerCell.text = response;
                              },
                            ),
                          ),
                          Flexible(
                            child: TextField(
                              controller: textControllerCell,
                              decoration: const InputDecoration(
                                hintText: 'QR code',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: IconButton(
                              icon: const Icon(
                                MdiIcons.qrcodeScan,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                const int single = 1;
                                final dynamic response = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BarcodeScannerWithController(
                                                single: single)));
                                textControllerSE.text = response;
                              },
                            ),
                          ),
                          Flexible(
                            child: TextField(
                              controller: textControllerSE,
                              decoration: const InputDecoration(
                                hintText: 'SE QR code',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ignore: avoid_unnecessary_containers
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                          ),
                          Flexible(
                            child: DropdownButton<String>(
                              value: selectedPlace,
                              isExpanded: true,
                              hint: const Text('Place'),
                              underline: Container(
                                height: 1,
                                color: Colors.blue,
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedPlace = newValue!;
                                  //empty other values
                                  location = '';
                                  locationList = [];
                                  locationid = '';
                                  locationidList = [];
                                  drawer = '';
                                  drawerList = [];
                                  // get new values for next list
                                  if (selectedPlace == 'Confinement') {
                                    locationList = locationOptionsConf;
                                  } else if (selectedPlace == 'GuideHall') {
                                    locationList = locationOptionsGuide;
                                  } else if (selectedPlace == 'Lab') {
                                    locationList = locationOptionsLab;
                                  } else {
                                    locationList = locationOptionsOther;
                                  }
                                  // set the first items as default
                                  if (locationList.isNotEmpty) {
                                    location = locationList[0];
                                    if (location == 'BT1') {
                                      locationidList = bt1locid;
                                    } else if (location == 'BT2') {
                                      locationidList = bt2locid;
                                    } else if (location == 'BT4') {
                                      locationidList = bt4locid;
                                    } else if (location == 'BT5') {
                                      locationidList = bt5locid;
                                    } else if (location == 'BT7') {
                                      locationidList = bt7locid;
                                    } else if (location == 'BT8') {
                                      locationidList = bt8locid;
                                    } else if (location == 'MACS') {
                                      locationidList = macslocid;
                                    } else if (location == 'East') {
                                      locationidList = guideEASTlocid;
                                    } else if (location == 'North') {
                                      locationidList = guideNORTHlocid;
                                    } else if (location == 'SPINS') {
                                      locationidList = guideSPINSlocid;
                                    } else if (location == 'A115') {
                                      locationidList = a115locid;
                                    } else if (location == 'A117') {
                                      locationidList = a117locid;
                                    } else if (location == 'A127') {
                                      locationidList = a127locid;
                                    } else if (location == 'A132') {
                                      locationidList = a132locid;
                                    } else if (location == 'B147') {
                                      locationidList = b147locid;
                                    } else if (location == 'B142') {
                                      locationidList = b142locid;
                                    } else if (location == 'E131') {
                                      locationidList = e131locid;
                                    } else if (location == 'E133') {
                                      locationidList = e133locid;
                                    } else if (location == 'E132') {
                                      locationidList = e132locid;
                                    } else if (location == 'E134') {
                                      locationidList = e134locid;
                                    } else if (location == 'E135') {
                                      locationidList = e135locid;
                                    } else if (location == 'E136') {
                                      locationidList = e136locid;
                                    } else if (location == 'E137') {
                                      locationidList = e137locid;
                                    } else if (location == 'E138') {
                                      locationidList = e138locid;
                                    } else if (location == 'HP_Clear') {
                                      locationidList = hplocid;
                                    } else if (location == 'Shipped back') {
                                      locationidList = shiplocid;
                                    } else if (location == 'Waste') {
                                      locationidList = [""];
                                    } else {
                                      locationidList = guideINSTlocid;
                                    }
                                    if (locationidList.isNotEmpty) {
                                      locationid = locationidList[0];
                                      if (locationid == 'Black Cab') {
                                        drawerList = cabinetdrawer;
                                      } else if (locationid == 'Beige Cab') {
                                        drawerList = cabinetdrawer;
                                      } else if (locationid == 'Grey Cab') {
                                        drawerList = cabinetdrawer;
                                      } else if (locationid == 'Cream Cab') {
                                        drawerList = otherdrawer;
                                      } else if (locationid == 'Cabinet') {
                                        drawerList = otherdrawer;
                                      } else if (locationid == 'Bank 2') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 13') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 14') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 15') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 16') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 18') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 19') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 17') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 4') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 7') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 20') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 21') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 22') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 23') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 24') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Bank 25') {
                                        drawerList = bankdrawer;
                                      } else if (locationid == 'Freezer') {
                                        drawerList = drawer5;
                                      } else if (locationid == 'Argon box') {
                                        drawerList = drawer4;
                                      } else if (locationid ==
                                          'Freezer4-Left') {
                                        drawerList = drawer4;
                                      } else if (locationid ==
                                          'Freezer4-Right') {
                                        drawerList = drawer4;
                                      } else if (locationid == 'Fridge-Left') {
                                        drawerList = drawer6;
                                      } else if (locationid ==
                                          'Fridge-Right') {
                                        drawerList = drawer6;
                                      } else {
                                        drawerList = [""];
                                      }
                                      if (drawerList.isNotEmpty) {
                                        drawer = drawerList[0];
                                      }
                                    }
                                  }
                                });
                              },
                              items: placeOptions
                                  .map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ignore: avoid_unnecessary_containers

                    // ignore: avoid_unnecessary_containers
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                          ),
                          Flexible(
                            child: DropdownButton<String>(
                              value: location,
                              isExpanded: true,
                              hint: const Text('location'),
                              underline: Container(
                                height: 1,
                                color: Colors.blue,
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  location = newValue!;
                                  //empty other values
                                  locationid = '';
                                  locationidList = [];
                                  drawer = '';
                                  drawerList = [];
                                  // get new values for next list
                                  if (location == 'BT1') {
                                    locationidList = bt1locid;
                                  } else if (location == 'BT2') {
                                    locationidList = bt2locid;
                                  } else if (location == 'BT4') {
                                    locationidList = bt4locid;
                                  } else if (location == 'BT5') {
                                    locationidList = bt5locid;
                                  } else if (location == 'BT7') {
                                    locationidList = bt7locid;
                                  } else if (location == 'BT8') {
                                    locationidList = bt8locid;
                                  } else if (location == 'MACS') {
                                    locationidList = macslocid;
                                  } else if (location == 'East') {
                                    locationidList = guideEASTlocid;
                                  } else if (location == 'North') {
                                    locationidList = guideNORTHlocid;
                                  } else if (location == 'SPINS') {
                                    locationidList = guideSPINSlocid;
                                  } else if (location == 'A115') {
                                    locationidList = a115locid;
                                  } else if (location == 'A117') {
                                    locationidList = a117locid;
                                  } else if (location == 'A127') {
                                    locationidList = a127locid;
                                  } else if (location == 'A132') {
                                    locationidList = a132locid;
                                  } else if (location == 'B147') {
                                    locationidList = b147locid;
                                  } else if (location == 'B142') {
                                    locationidList = b142locid;
                                  } else if (location == 'E131') {
                                    locationidList = e131locid;
                                  } else if (location == 'E133') {
                                    locationidList = e133locid;
                                  } else if (location == 'E132') {
                                    locationidList = e132locid;
                                  } else if (location == 'E134') {
                                    locationidList = e134locid;
                                  } else if (location == 'E135') {
                                    locationidList = e135locid;
                                  } else if (location == 'E136') {
                                    locationidList = e136locid;
                                  } else if (location == 'E137') {
                                    locationidList = e137locid;
                                  } else if (location == 'E138') {
                                    locationidList = e138locid;
                                  } else if (location == 'HP_Clear') {
                                    locationidList = hplocid;
                                  } else if (location == 'Shipped back') {
                                    locationidList = shiplocid;
                                  } else if (location == 'Waste') {
                                    locationidList = [""];
                                  } else {
                                    locationidList = guideINSTlocid;
                                  }
                                  // set the first item as default
                                  if (locationidList.isNotEmpty) {
                                    locationid = locationidList[0];
                                    if (locationid == 'Black Cab') {
                                      drawerList = cabinetdrawer;
                                    } else if (locationid == 'Beige Cab') {
                                      drawerList = cabinetdrawer;
                                    } else if (locationid == 'Grey Cab') {
                                      drawerList = cabinetdrawer;
                                    } else if (locationid == 'Cream Cab') {
                                      drawerList = otherdrawer;
                                    } else if (locationid == 'Cabinet') {
                                      drawerList = otherdrawer;
                                    } else if (locationid == 'Bank 2') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 13') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 14') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 15') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 16') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 18') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 19') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 17') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 4') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 7') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 20') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 21') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 22') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 23') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 24') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 25') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Freezer') {
                                      drawerList = drawer5;
                                    } else if (locationid == 'Argon box') {
                                      drawerList = drawer4;
                                    } else if (locationid == 'Freezer4-Left') {
                                      drawerList = drawer4;
                                    } else if (locationid ==
                                        'Freezer4-Right') {
                                      drawerList = drawer4;
                                    } else if (locationid == 'Fridge-Left') {
                                      drawerList = drawer6;
                                    } else if (locationid == 'Fridge-Right') {
                                      drawerList = drawer6;
                                    } else {
                                      drawerList = [""];
                                    }
                                    if (drawerList.isNotEmpty) {
                                      drawer = drawerList[0];
                                    }
                                  }
                                });
                              },
                              items: locationList
                                  .map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //_addThirdDropdown locationid(),

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                          ),
                          Flexible(
                            child: Opacity(
                              opacity: (locationid == "") ? 0 : 1,
                              child: DropdownButton<String>(
                                value: locationid,
                                isExpanded: true,
                                hint: const Text('Location ID'),
                                underline: Container(
                                  height: 1,
                                  color: Colors.blue,
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    locationid = newValue!;
                                    drawer = "";
                                    drawerList = [];
                                    // get new values for next list
                                    if (locationid == 'Black Cab') {
                                      drawerList = cabinetdrawer;
                                    } else if (locationid == 'Beige Cab') {
                                      drawerList = cabinetdrawer;
                                    } else if (locationid == 'Grey Cab') {
                                      drawerList = cabinetdrawer;
                                    } else if (locationid == 'Cream Cab') {
                                      drawerList = otherdrawer;
                                    } else if (locationid == 'Cabinet') {
                                      drawerList = otherdrawer;
                                    } else if (locationid == 'Bank 2') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 13') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 14') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 15') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 16') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 18') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 19') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 17') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 4') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 7') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 20') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 21') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 22') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 23') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 24') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Bank 25') {
                                      drawerList = bankdrawer;
                                    } else if (locationid == 'Freezer') {
                                      drawerList = drawer5;
                                    } else if (locationid == 'Argon box') {
                                      drawerList = drawer4;
                                    } else if (locationid == 'Freezer4-Left') {
                                      drawerList = drawer4;
                                    } else if (locationid ==
                                        'Freezer4-Right') {
                                      drawerList = drawer4;
                                    } else if (locationid == 'Fridge-Left') {
                                      drawerList = drawer6;
                                    } else if (locationid == 'Fridge-Right') {
                                      drawerList = drawer6;
                                    } else {
                                      drawerList = [""];
                                    }
                                    if (drawerList.isNotEmpty) {
                                      drawer = drawerList[0];
                                    }
                                  });
                                },
                                items: locationidList
                                    .map<DropdownMenuItem<String>>((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                          ),
                          Flexible(
                            child: Opacity(
                              opacity: (drawer == "") ? 0 : 1,
                              child: DropdownButton<String>(
                                value: drawer,
                                isExpanded: true,
                                hint: const Text('Drawer/shelf'),
                                underline: Container(
                                  height: 1,
                                  color: Colors.blue,
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    drawer = newValue!;
                                  });
                                },
                                items: drawerList
                                    .map<DropdownMenuItem<String>>((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    FormBuilderTextField(
                      keyboardType: TextInputType.multiline,
                      focusNode: _nodeText6,
                      name: "extra_notes",
                      onSaved: (value) {
                        widget.sample.extraNotes = value;
                      },
                      decoration: const InputDecoration(
                        labelText: "Extra Notes",
                        icon: Icon(Icons.format_list_bulleted),
                      ),
                      // validator: FormBuilderValidators.compose([
                      //   FormBuilderValidators.minWordsCount(0),
                      //   FormBuilderValidators.maxWordsCount(180),
                      // ]),
                    ),

                    FormBuilderSwitch(
                      title: const Text('Archive this sample?'),
                      name: "archived",
                      initialValue: _arch,
                      onSaved: (value) {
                        widget.sample.archived = value.toString();
                      },
                      decoration: const InputDecoration(
                        icon: Icon(MdiIcons.trashCan, color: Colors.grey),
                      ),
                    ),

                    ListTile(
                      title: Row(
                        children: <Widget>[
                          Expanded(

                              /// Just navigate back on cancel.
                              child: ElevatedButton(
                            onPressed: () {
                              _fbKey.currentState!.reset();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                            child: const Text("Cancel"),
                          )),
                          Expanded(
                            /// format the state value and send to
                            /// and API call eventually.
                            child: ElevatedButton(
                                onPressed: () {
                                  if (_fbKey.currentState!.saveAndValidate()) {
                                    final container =
                                        MyInheritedWidget.of(context, false);

                                    /// Also these updated fields/                                ///

                                    if (selectedPlace != widget.sample.place) {
                                      widget.sample.place = selectedPlace;
                                    }
                                    if (location != widget.sample.location) {
                                      widget.sample.location = location;
                                    }
                                    if (locationid !=
                                        widget.sample.locationid) {
                                      widget.sample.locationid = locationid;
                                    }
                                    if (drawer != widget.sample.drawer) {
                                      widget.sample.drawer = drawer;
                                    }

                                    //Sometimes files dont have the right form... can uncomment this and
                                    // then every time you save a sample it will change
                                    // widget.sample.form = "Powder";
                                    //widget.sample.username =
                                    //    "mikael.andersson@nist.gov";
                                    //widget.sample.owner = "Mikael Andersson";
                                    //
                                    //
                                    widget.sample.parent = "0";

                                    widget.sample.date =
                                        DateFormat('yyyy-MM-dd')
                                            .format(DateTime.now());

                                    /// XXX This is where the call is made to save the data.
                                    /// //convert string to int then string
                                    widget.sample.sampleId = (int.parse(
                                            widget.sample.sampleId.toString())
                                        .toString());

/*                                  it is convenient if names get messed up to fix here.
                                    widget.sample.owner = "Yun Liu";
                                    widget.sample.username = "Yun.Liu@nist.gov"; */

                                    //update
                                    final myFuture = API.updateSample(
                                        container.getjwt,
                                        sample: widget.sample);
                                    myFuture.then((response) {
                                      if (response != null) {
                                        var id = response['sample_id'];
                                        print(id);
                                        Future.delayed(
                                            const Duration(seconds: 1));
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context)
                                            .pushNamed('/myhome');
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        toast(context, "Error moving sample",
                                            Colors.red);
                                        // Navigator.of(context)
                                        //     .pushNamed('/myhome');
                                      }
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18.0),
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                                child: const Text("Submit")),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
