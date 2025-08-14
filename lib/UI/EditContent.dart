import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../Functions/barcode_scanner_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/Sample.dart';
import '../API.dart';
import '../main.dart';
import 'Toast.dart';
import 'data.dart';

///This could be StatelessWidget but it won't work on Dialogs for now until this issue is fixed: https://github.com/flutter/flutter/issues/45839
/// I think I prefer the stateful widget: I need to call values anyway.

class EditContent extends StatefulWidget {
  /// passed in values
  /// Need to check if these are set-if not dafault to empty new sample, and status = new

  final Sample? sample;
  final String status;

  const EditContent({super.key, this.sample, required this.status});

  /// @override is not neccesary, but indicates we want to do this purposefully
  @override
  // ignore: library_private_types_in_public_api
  _EditContentState createState() => _EditContentState();
}

class _EditContentState extends State<EditContent> {
  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);

  final picker = ImagePicker();
  bool changedImage = false;

  /// need a class for the focusnode to operate between each widget.
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();
  final FocusNode _nodeText5 = FocusNode();
  final FocusNode _nodeText6 = FocusNode();
  final FocusNode _nodeText7 = FocusNode();
  final FocusNode _nodeText8 = FocusNode();
  final FocusNode _nodeText9 = FocusNode();
  final FocusNode _nodeText10 = FocusNode();
  final FocusNode _nodeText11 = FocusNode();

  @override
  initState() {
    setState(() {});
    super.initState();
  }

  Future<File> getImageFileFromAssets(String image) async {
    final byteData = await rootBundle.load('assets/images/$image');
    final file = File('${(await getTemporaryDirectory()).path}/$image');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  Future<File> resizeImage(File imageFile, int maxWidth) async {
    final img.Image? originalImage =
        img.decodeImage(await imageFile.readAsBytes());
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    final resizedImage = img.copyResize(originalImage, width: maxWidth);
    final resizedBytes = img.encodePng(resizedImage);

    final resizedFile = File('${imageFile.path}_resized.png');
    await resizedFile.writeAsBytes(resizedBytes);

    return resizedFile;
  }

  void openGallery() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      if (result.files.first.path != null) {
        File image = File(result.files.first.path!);
        final resizedImage = await resizeImage(image, 1000);

        setState(() {
          _image = File(image.path);
          _image = resizedImage;
          changedImage = true;
        });
      }
    }

    // if (Platform.isIOS || Platform.isAndroid) {
    //   final image = await picker.pickImage(
    //     source: ImageSource.gallery,
    //     maxWidth: 800,
    //     maxHeight: 800,
    //     imageQuality: 30,
    //   );
    //   if (image != null) {
    //     setState(() {
    //       this._image = File(image.path);
    //       changedImage = true;
    //     });
    //   }
    // } else {
    //   try {
    //     final result = await pickFiles(
    //         allowMultiple: false,
    //         type: FileType.custom,
    //         allowedExtensions: ['jpg', 'png', 'gif']);
    //     if (result != null) {
    //       setState(() {
    //         this._image = File(result.files.single.path.toString());
    //         changedImage = true;
    //       });
    //     }
    //   } catch (e) {
    //     print(e);
    //   }
    // }
  }

  void openCamera() async {
    var image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 30,
    );
    if (image != null) {
      setState(() {
        _image = File(image.path);
        changedImage = true;
      });
    }
  }

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
        KeyboardActionsItem(focusNode: _nodeText7, toolbarButtons: [
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
        KeyboardActionsItem(focusNode: _nodeText8, toolbarButtons: [
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
        KeyboardActionsItem(focusNode: _nodeText9, toolbarButtons: [
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
        KeyboardActionsItem(focusNode: _nodeText10, toolbarButtons: [
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
        KeyboardActionsItem(focusNode: _nodeText11, toolbarButtons: [
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

  String unit = ""; // init units
  String haz1 = ""; // init hazard lists
  String haz2 = "";
  String haz3 = "";
  String haz4 = "";
  String selectedPlace = "";
  String location = "";
  List locationList = [];
  String locationid = "";
  List locationidList = [];
  String drawer = "";
  var date = DateTime.now();
  List drawerList = [];
  String _form = ""; // init form of sample
  //int _formIndex = -1; // init form of sample index for the cupertino selector
  bool _arch = false; // init bool for archived or not
  String username = "";
  String owner = "";
  String usernameOrig =
      ""; // Hold these two as originals to see if they are changed.
  String ownerOrig = "";

  List emailList = [];
  List nameList = [];
  int emailIndex = -1;
  String name = "";
  String email = "";
  bool admin = false;

  String cellbarcode = '';
  String sampenvbarcode = '';

  List<dynamic> allHazards = [];
  List<dynamic> allForms = [];
  List<dynamic> allUnits = [];

  late Image backgroundImage;
  //late File _image;
  File _image = File('your initial file');
  String origId = "";
  bool exec =
      true; // this is just to set the values to default to the sample values once on widget build

  final textControllerCell = TextEditingController();
  final textControllerSE = TextEditingController();

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    //CMB 08/22 final scanResult = this.scanResult;
    //inherited widget works!
    final container = MyInheritedWidget.of(context, false);

    // get the value of the page status: edit/copy/new for a sample
    String status = widget.status.toString();
    print("Status of page: $status");

    // check what we are doing
    if (status == 'edit') {
      (widget.sample?.imageURL != "")
          ? backgroundImage =
              Image.network(widget.sample!.imageURL.toString()) //CMB
          : backgroundImage = Image.asset("assets/images/ncnr.jpg");
    } else {
      backgroundImage = Image.asset("assets/images/ncnr.jpg");
    }

    // get absolute path of background file

    /// i.e. execute once to set radio button units based on input sample or simple defaults.
    /// Will throw an error accessing widget.sample if it is empty!
    if (exec) {
      var pp = true;
      origId = widget.sample!.sampleId.toString();
      if (pp && status != 'new') {
        print("ID$origId");
        try {
          print("Haz1: ${widget.sample!.haz1}");
        } on Error {
          // ignore: unnecessary_statements
          null;
        }
      }
      allHazards = container.sampleHazards;
      allForms = container.sampleForms;
      allUnits = container.sampleUnits;

      if (status == 'new') {
        unit = "g";
      } else {
        unit = ((widget.sample?.unit != "") ? widget.sample?.unit : "g")!;
      }

      if (status == 'new') {
        _form = "Powder";
      } else {
        if (widget.sample?.form != null) {
          _form =
              ((widget.sample?.form != "") ? widget.sample?.form : "Powder")!;
        }
      }
      if (pp) {
        print("form $_form");
      }
      //_formIndex = container.sampleForms.indexOf(_form);
      if (status == 'new') {
        _arch = false;
      } else {
        if (widget.sample?.archived != null) {
          _arch = (widget.sample!.archived == "0") ? false : true;
        }
      }

      if (status == 'new') {
        selectedPlace = "Confinement";
      } else {
        selectedPlace = ((widget.sample!.place != "")
            ? widget.sample!.place
            : "Confinement")!;
      }
      if (pp) {
        print("selectedPlace $selectedPlace");
      }
      if (status == 'edit') {
        if (widget.sample?.cellbarcode != null) {
          cellbarcode = (widget.sample!.cellbarcode == ""
              ? ""
              : widget.sample!.cellbarcode)!;
        }
        if (widget.sample?.sampenvbarcode != null) {
          sampenvbarcode = (widget.sample!.sampenvbarcode == ""
              ? ""
              : widget.sample!.sampenvbarcode)!;
        }
      } else {
        cellbarcode = "";
        sampenvbarcode = "";
      }
      if (pp) {
        print("cellbarcode $cellbarcode");
      }
      if (pp) {
        print("sampenvbarcode $sampenvbarcode");
      }
      if (status != 'new') {
        try {
          owner = ((widget.sample!.username == "")
              ? container.userEmail
              : widget.sample!.username)!;
          username = ((widget.sample!.owner == "")
              ? container.userName
              : widget.sample!.owner)!;
          usernameOrig = username;
          ownerOrig = owner;
          name = container.userName;
          email = container.userEmail;
          admin = container.admin;
          emailList = container.emailList;
          nameList = container.userList;
          emailIndex = container.userIndex;
          // just make sure that an admin does not edit users:
          if (owner != email) {
            emailIndex =
                emailList.indexWhere((emailList) => emailList == owner);
          }
          // incase of previous user email errors:
          // if (owner == "judith.stalick@nist.gov") {
          //   owner = "judith.stalick@nist.gov";
          //   emailIndex = emailList.indexWhere((emailList) => emailList == owner);
          //   username = nameList[emailIndex];
          //   // print(emailIndex);
          //   // print(emailList[emailIndex]);
          //   // print(nameList[emailIndex]);
          // }
        } on Error {
          print(
              "There was an unanticipted error. If you got here... let us know!");
        }
      } else {
        usernameOrig = username;
        ownerOrig = owner;
        name = username;
        email = owner;
        admin = container.admin;
        emailList = container.emailList;
        nameList = container.userList;
        emailIndex = container.userIndex;
      }

      // a bit more fanigling as we are doing 3 things with this one form
      if (owner == "") {
        owner = container.userEmail;
        ownerOrig = owner;
      }
      if (username == "") {
        username = container.userName;
        usernameOrig = username;
      } //email
      if (admin == false) {
        emailList = [owner];
        nameList = [username];
        emailIndex = 0;
      }
      if (pp) {
        print("username $username");
        print("owner $owner");
        print("name $name");
        print("email $email");
        print("admin $admin");
      }
      if (selectedPlace == "") {
        selectedPlace = "Confinement";
        unit = "g";
        _form = "Powder";
      }
      try {
        if (status == 'new') {
          date = DateTime.now();
        } else {
          if (widget.sample?.date != null) {
            date = (widget.sample?.date != "")
                ? DateTime.parse(widget.sample!.date.toString()) //CMB
                : DateTime.now();
          }
        }
      } on Error {
        // ignore: unnecessary_statements
        null;
      }
      // get values for next list

      if (selectedPlace == 'Confinement') {
        locationList = locationOptionsConf;
      } else if (selectedPlace == 'GuideHall') {
        locationList = locationOptionsGuide;
      } else if (selectedPlace == 'Lab') {
        locationList = locationOptionsLab;
      } else {
        locationList = locationOptionsOther;
      }
      if (pp && status != 'new') {
        print("selectedPlace from json ${widget.sample!.place}");
        print("location from json ${widget.sample!.location}");
        print("location id from json ${widget.sample!.locationid}");
        print("drawer from json ${widget.sample!.drawer}");
      }
      if (status != 'new') {
        location =
            ((widget.sample!.location != "" || widget.sample?.location != " ")
                ? widget.sample!.location
                : "")!;
      }
      // get values for next list
      if (pp) {
        print("selectedPlace $selectedPlace");
        print("location $location");
      }

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

      if (widget.sample?.locationid != null) {
        locationid = ((widget.sample!.locationid != "")
            ? widget.sample!.locationid
            : "")!;
      }

      if (pp) {
        print("locationid $locationid");
      }
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

      if (widget.sample?.drawer != null) {
        drawer = ((widget.sample!.drawer != "") ? widget.sample!.drawer : "")!;
      }

      exec = false;
      if (pp) {
        print("drawer $drawer");
      }

      if (status != 'new') {
        if (widget.sample?.haz1 != null) {
          haz1 = ((widget.sample?.haz1 != "") ? widget.sample?.haz1 : "")!;
        }
        if (widget.sample?.haz2 != null) {
          haz2 = ((widget.sample?.haz2 != "") ? widget.sample?.haz2 : "")!;
        }
        if (widget.sample?.haz3 != null) {
          haz3 = ((widget.sample?.haz3 != "") ? widget.sample?.haz3 : "")!;
        }
        if (widget.sample?.haz4 != null) {
          haz4 = ((widget.sample?.haz4 != "") ? widget.sample?.haz4 : "")!;
        }
      }
// // DELETE ME
//       selectedPlace = 'Confinement';
//       locationList = locationOptionsConf;
//       locationidList = [""];
//       drawerList = [];
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
                  'chemical': widget.sample!.chemical,
                  'sample_name': widget.sample!.sampleName,
                  'external_user': widget.sample!.externalUser,
                  'added': date,
                  'quantity': widget.sample!.quantity,
                  'cellbarcode': cellbarcode,
                  'sampenvbarcode': sampenvbarcode,
                  'extra_notes': widget.sample!.extraNotes,
                  'archived': widget.sample!.archived,
                  'Haz1': haz1,
                  'Haz2': haz2,
                  'Haz3': haz3,
                  'Haz4': haz4,
                  'units': unit,
                  'form': _form,
                  'place': selectedPlace,
                  'location': location,
                  'locationID': locationid,
                  'drawer': drawer,
                  'username': owner,
                  //'Name': "",
                  //'Username': "",
                },

                /// This is where the widget tree starts being built
                ///
                child: Column(
                  children: <Widget>[
                    FormBuilderTextField(
                      keyboardType: TextInputType.text,
                      focusNode: _nodeText1,
                      name: "chemical",
                      onSaved: (value) {
                        widget.sample!.chemical = value;
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
                        widget.sample!.sampleName = value;
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
                        widget.sample!.externalUser = value;
                      },
                      decoration: const InputDecoration(
                        labelText: "External User",
                        icon: Icon(Icons.child_friendly),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.maxWordsCount(70),
                      ]),
                    ),
                    FormBuilderDateTimePicker(
                      name: "added",
                      inputType: InputType.date,
                      format: DateFormat("yyyy-MM-dd"),
                      onSaved: (value) {
                        var value2 = value.toString();
                        widget.sample!.added = value2;
                      },
                      decoration: const InputDecoration(
                        labelText: "Recieved on",
                        icon: Icon(Icons.calendar_today),
                      ),
                    ),
                    FormBuilderTextField(
                      focusNode: _nodeText4,
                      name: "quantity",
                      onSaved: (value) {
                        widget.sample!.quantity = value;
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: "Mass", icon: Icon(Icons.fitness_center)),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                      ]),
                    ),
                    const SizedBox(height: 15),

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Icon(
                              MdiIcons.scaleBalance,
                              color: Colors.grey[600],
                            ),
                          ),
                          Flexible(
                              child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'select mass units'),
                                  value: unit,
                                  items: allUnits
                                      .map((label) => DropdownMenuItem(
                                            value: label,
                                            child: Text(label),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      unit = value.toString();
                                      widget.sample!.unit = value.toString();
                                    });
                                  })),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// cupertino scroll for sample form.
                    /// This might look terrible - perhaps change.
                    ///
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Icon(
                              MdiIcons.diamond,
                              color: Colors.grey[600],
                            ),
                          ),
                          Flexible(
                              child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'select sample form'),
                                  value: _form,
                                  items: allForms
                                      .map((label) => DropdownMenuItem(
                                            value: label,
                                            child: Text(label),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _form = value.toString();
                                      widget.sample!.form = value.toString();
                                    });
                                  })),
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
                                  const single = 1;
                                  final dynamic response =
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BarcodeScannerWithController(
                                                      single: single)));

                                  if (response != '' ||
                                      response != '-1' ||
                                      response != -1) {
                                    setState(() {
                                      textControllerCell.text = response;
                                      cellbarcode = response;
                                    });
                                  } else {
                                    textControllerCell.text = '';
                                    cellbarcode = '';
                                  }
                                }),
                          ),
                          Flexible(
                            child: TextField(
                              controller: textControllerCell,
                              decoration: const InputDecoration(
                                hintText: 'QR code',
                              ),
                            ),

                            // child: FormBuilderTextField(
                            //   keyboardType: TextInputType.text,
                            //   focusNode: _nodeText5,
                            //   onChanged: (val) {
                            //     // XXX do we need this?
                            //     bool inList = false;
                            //     // check to see if in cellLists
                            //     container.eAl16List.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eAl12List.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eAl31List.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eAl63List.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eDCSList.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eSSList.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eBrookhavenEList.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eOtherList.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eVanAList.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eVanBList.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eVanCList.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eVanDList.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     container.eVanEList.forEach((element) {
                            //       if (element.barcode == val) {
                            //         inList = true;
                            //       }
                            //     });
                            //     if (val == "") {
                            //       inList = true;
                            //     }
                            //     if (inList) {
                            //       print('in list');
                            //       widget.sample.cellbarcode = val;
                            //     } else {
                            //       print('Cell is not in the database');
                            //     }
                            //   },
                            //   name: (sampenvbarcode == "")
                            //       ? "Enter QR code"
                            //       : "$sampenvbarcode",
                            //   decoration: InputDecoration(labelText: "QR code"),

                            //   // validators: [
                            //   //   (val) {
                            //   //   },
                            //   // ],
                            // ),
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
                                  final dynamic response =
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BarcodeScannerWithController(
                                                      single: single)));

                                  if (response != '' ||
                                      response != '-1' ||
                                      response != -1) {
                                    setState(() {
                                      sampenvbarcode = response;
                                      textControllerSE.text = response;
                                    });
                                  } else {
                                    textControllerSE.text = '';
                                    sampenvbarcode = '';
                                  }
                                }),
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

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Icon(
                              MdiIcons.skullCrossbones,
                              color: Colors.red,
                            ),
                          ),
                          Flexible(
                              child: DropdownButtonFormField(
                            decoration:
                                const InputDecoration(labelText: 'select hazard 1'),
                            value: haz1,
                            items: allHazards // container.sampleHazards
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                haz1 = value.toString();
                                widget.sample!.haz1 = value.toString();
                              });
                            },
                          )),
                        ],
                      ),
                    ),

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Icon(
                              MdiIcons.skullCrossbones,
                              color: Colors.red,
                            ),
                          ),
                          Flexible(
                              child: DropdownButtonFormField(
                            decoration:
                                const InputDecoration(labelText: 'select hazard 2'),
                            value: haz2,
                            items: allHazards // container.sampleHazards
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                haz2 = value.toString();
                                widget.sample!.haz2 = value.toString();
                              });
                            },
                          )),
                        ],
                      ),
                    ),

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Icon(
                              MdiIcons.skullCrossbones,
                              color: Colors.red,
                            ),
                          ),
                          Flexible(
                              child: DropdownButtonFormField(
                            decoration:
                                const InputDecoration(labelText: 'select hazard 3'),
                            value: haz3,
                            items: allHazards // container.sampleHazards
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                haz3 = value.toString();
                                widget.sample!.haz3 = value.toString();
                              });
                            },
                          )),
                        ],
                      ),
                    ),

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Icon(
                              MdiIcons.skullCrossbones,
                              color: Colors.red,
                            ),
                          ),
                          Flexible(
                              child: DropdownButtonFormField(
                            decoration:
                                const InputDecoration(labelText: 'select hazard 4'),
                            value: haz4,
                            items: allHazards // container.sampleHazards
                                .map((label) => DropdownMenuItem(
                                      value: label,
                                      child: Text(label),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                haz4 = value.toString();
                                widget.sample!.haz4 = value.toString();
                              });
                            },
                          )),
                        ],
                      ),
                    ),

                    FormBuilderTextField(
                      keyboardType: TextInputType.multiline,
                      focusNode: _nodeText7,
                      name: "extra_notes",
                      onSaved: (value) {
                        widget.sample!.extraNotes = value;
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
                      onSaved: (value) {
                        widget.sample!.archived = value.toString();
                      },
                      initialValue: _arch,
                      decoration: const InputDecoration(
                        icon: Icon(MdiIcons.trashCan, color: Colors.grey),
                      ),
                    ),

                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Icon(
                              MdiIcons.human,
                              color: Colors.grey,
                            ),
                          ),
                          Flexible(
                            child: DropdownButton<String>(
                              value: username,
                              // IF THE USER IS NOT IN THE DATABASE LIST. EDIT HERE THE NAME.
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(
                                color:
                                    admin ? Colors.grey[700] : Colors.grey[400],
                              ),
                              underline: Container(
                                height: 2,
                              ),
                              onChanged: (String? newValue) {
                                admin
                                    ? setState(() {
                                        emailIndex = nameList.indexWhere(
                                            (nameList) => nameList == newValue);
                                        username = newValue.toString();
                                      })
                                    // ignore: unnecessary_statements
                                    : null;
                              },
                              items: nameList
                                  .map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem<String>(
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
                    Container(
                      child: Row(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(45, 0, 00, 0),
                          ),
                          Flexible(
                            child: Text(
                              emailList[emailIndex],
                              style: TextStyle(
                                color:
                                    admin ? Colors.grey[700] : Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Center(
                        // ignore: avoid_unnecessary_containers
                        child: Container(
                      child: Column(
                        children: [
                          Stack(children: <Widget>[
                            Container(
                              color: Colors.black12,
                              height: 300.0,
                              width: 300.0,
                              child: (_image.path == "your initial file")
                                  ? backgroundImage
                                  : Image.file(_image),
                            ),
                            Positioned(
                                right: -10.0,
                                bottom: 2.0,
                                child: RawMaterialButton(
                                  onPressed: () async {
                                    File f = await getImageFileFromAssets(
                                        'ncnr.jpg');
                                    setState(() {
                                      _image = f;
                                      changedImage = true;
                                    });
                                  },
                                  fillColor: Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 4.0,
                                  child: const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 17,
                                      )),
                                ))
                          ]),
                          ListTile(
                              title: Row(
                            children: <Widget>[
                              Expanded(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        openGallery();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: const BorderSide(color: Colors.red),
                                        ),
                                      ),
                                      child: const Text("Open Gallery"))),
                              (defaultTargetPlatform == TargetPlatform.iOS ||
                                      defaultTargetPlatform ==
                                          TargetPlatform.android)
                                  ? Expanded(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            openCamera();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      18.0),
                                              side:
                                                  const BorderSide(color: Colors.red),
                                            ),
                                          ),
                                          child: const Text("Open Camera")),
                                    )
                                  : const Expanded(
                                      child: TextButton(
                                        onPressed: null,
                                        child: Text(""),
                                      ),
                                    )
                            ],
                          )),
                        ],
                      ),
                    )),

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
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0),
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  child: const Text("Cancel"))),
                          Expanded(
                            /// format the state value and send to
                            /// and API call eventually.
                            child: ElevatedButton(
                                onPressed: () {
                                  if (_fbKey.currentState!.saveAndValidate()) {
                                    /// these are the values that the formbuild and customformbuilder fails on

                                    /// Also these updated fields/                                ///
                                    if (unit != widget.sample!.unit) {
                                      widget.sample!.unit = unit;
                                    }
                                    if (selectedPlace != widget.sample!.place) {
                                      widget.sample!.place = selectedPlace;
                                    }
                                    if (location != widget.sample!.location) {
                                      widget.sample!.location = location;
                                    }
                                    if (locationid !=
                                        widget.sample!.locationid) {
                                      widget.sample!.locationid = locationid;
                                    }
                                    if (drawer != widget.sample!.drawer) {
                                      widget.sample!.drawer = drawer;
                                    }
                                    // if (sampenvbarcode !=
                                    //     widget.sample!.sampenvbarcode) {
                                    //   widget.sample!.sampenvbarcode =
                                    //       sampenvbarcode;
                                    // }
                                    print('cell $cellbarcode');
                                    print(widget.sample!.cellbarcode);
                                    print('SE $sampenvbarcode');
                                    print(widget.sample!.sampenvbarcode);

                                    // if (cellbarcode !=
                                    //     widget.sample!.cellbarcode) {
                                    //   widget.sample!.cellbarcode = cellbarcode;
                                    // }
                                    widget.sample!.parent = "0";
                                    widget.sample!.owner = username;
                                    widget.sample!.username =
                                        emailList[emailIndex];

                                    widget.sample!.date =
                                        DateFormat('yyyy-MM-dd')
                                            .format(DateTime.now());

                                    /// i.e. if editing a sample we already have an ID.

                                    if (status == "edit") {
                                      // widget.sample?.sampleId = (int.parse(
                                      //         widget.sample!.sampleId
                                      //             .toString())
                                      //     .toString());
                                      //update
                                      final myFuture = API.updateSample(
                                          container.getjwt,
                                          sample: widget.sample!);
                                      myFuture.then((response) {
                                        if (response != null) {
                                          // print('sample updated');
                                          // print(widget.sample?.chemical);

                                          // ignore: unnecessary_null_comparison
                                          //if (this._image != null) {
                                          if (changedImage) {
                                            // print("Image changing");
                                            //must have changed the image: lets update
                                            var val = API.updateImage(
                                                container.getjwt,
                                                sampleID:
                                                    widget.sample?.sampleId,
                                                file: _image);
                                            if (val.toString().isNotEmpty) {
                                              // ignore: use_build_context_synchronously
                                              toast(context, "Sample cloned",
                                                  Colors.green);
                                            } else {
                                              toast(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                  "Error updating image",
                                                  Colors.red);
                                            }
                                          }
                                          Future.delayed(
                                              const Duration(seconds: 1));
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context)
                                              .pushNamed('/myhome');
                                        } else {
                                          // ignore: use_build_context_synchronously
                                          toast(context, "Error adding sample",
                                              Colors.red);
                                        }
                                      });
                                    } else if (status == "clone") {
                                      widget.sample?.sampleId = "";
                                      widget.sample?.cellbarcode = "";
                                      widget.sample?.sampenvbarcode = "";
                                      final myFuture = API.updateSample(
                                          container.getjwt,
                                          sample: widget.sample!);
                                      myFuture.then((response) {
                                        if (response != null) {
                                          //check if image changed than also update:

                                          if (changedImage) {
                                            print("Image changing");
                                            (const Duration(seconds: 5));

                                            //must have changed the image: lets update
                                            var val = API.updateImage(
                                                container.getjwt,
                                                sampleID:
                                                    widget.sample?.sampleId,
                                                file: _image);
                                            if (val.toString().isNotEmpty) {
                                              // ignore: use_build_context_synchronously
                                              toast(context, "Sample Cloned",
                                                  Colors.green);
                                            } else {
                                              toast(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                  "Error updating cloned image",
                                                  Colors.red);
                                            }
                                          }
                                          (const Duration(seconds: 2));

                                          // note that a cloned sample loses the image.
                                          // we want the toast to be read before pushing the next context
                                          // ignore: unnecessary_statements
                                          (const Duration(seconds: 1));
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context)
                                              .pushNamed('/myhome');
                                        } else {
                                          // have to clear widget sample?
                                          widget.sample?.sampleId = origId;

                                          // ignore: use_build_context_synchronously
                                          toast(context, "Error adding sample",
                                              Colors.red);
                                        }
                                      });
                                    } else if (status == "new") {
                                      widget.sample?.sampleId = "";
                                      // print("New Sample");
                                      // is there an image?
                                      // ignore: unnecessary_null_comparison
                                      if (_image != null) {
                                        // print("image present");

                                        if (Image.file(_image) !=
                                                backgroundImage &&
                                            _image.path !=
                                                "your initial file") {
                                          // print("And it is new");

                                          //must have changed the image.
                                          // create a sample then upload the image
                                          final myFuture =
                                              API.newSampleWithImage(
                                                  container.getjwt,
                                                  sample: widget.sample!,
                                                  image: _image);
                                          myFuture.then((response) {
                                            if (response != null) {
                                              // ignore: use_build_context_synchronously
                                              toast(context, "Sample created",
                                                  Colors.green);
                                              Future.delayed(
                                                  const Duration(seconds: 1));
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(context)
                                                  .pushNamed('/myhome');
                                            } else {
                                              // have to clear widget sample?
                                              widget.sample?.sampleId = origId;
                                              toast(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                  "Error adding sample",
                                                  Colors.red);
                                            }
                                          });
                                        } else {
                                          // just create a sample.
                                          // print("No new Image");

                                          final myFuture = API.updateSample(
                                              container.getjwt,
                                              sample: widget.sample!);
                                          myFuture.then((response) {
                                            if (response != null) {
                                              // print('new sample created');
                                              // ignore: use_build_context_synchronously
                                              toast(context, "New sample OK",
                                                  Colors.green);
                                              Future.delayed(
                                                  const Duration(seconds: 1));
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(context)
                                                  .pushNamed('/myhome');
                                            } else {
                                              // have to clear widget sample?
                                              widget.sample?.sampleId = origId;
                                              toast(
                                                  // ignore: use_build_context_synchronously
                                                  context,
                                                  "Error adding sample",
                                                  Colors.red);
                                            }
                                          });
                                        }
                                      } else {
                                        final myFuture = API.updateSample(
                                            container.getjwt,
                                            sample: widget.sample!);
                                        myFuture.then((response) {
                                          if (response != null) {
                                            // ignore: use_build_context_synchronously
                                            toast(context, "New sample OK",
                                                Colors.green);
                                            Future.delayed(
                                                const Duration(seconds: 1));
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context)
                                                .pushNamed('/myhome');
                                          } else {
                                            toast(
                                                // ignore: use_build_context_synchronously
                                                context,
                                                "Error aadding sample",
                                                Colors.red);
                                          }
                                        });
                                      }
                                    }
                                    //need a second delay here to ensure samples are refreshed properly
                                  } else {
                                    toast(
                                        context,
                                        "Error saving sample. Fix errors!",
                                        Colors.red);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18.0),
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                                child: const Text("Submit")),
                          ),
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
