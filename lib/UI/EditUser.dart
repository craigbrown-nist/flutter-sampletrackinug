import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import '../models/User.dart';
import '../API.dart';
import '../main.dart';
import 'Toast.dart';

import 'package:url_launcher/url_launcher.dart';

class EditUser extends StatefulWidget {
  final User user;
  const EditUser({super.key, required this.user});

  /// @override is not neccesary, but indicates we want to do this purposefully
  @override
  // ignore: library_private_types_in_public_api
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  /// need a class for the focusnode to operate between each widget.
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();
  final FocusNode _nodeText5 = FocusNode();

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
      ],
    );
  }

  bool _manager = false; // init bool for manager or not
  bool _arch = false; // init bool for archived or not
  // String _phone = "";
  String _barcode = "";
  String _email = "";
  String _name = "";
  String _address = "";
  final String _password = "";

  bool exec = true; // this is just to set the values to default

  final _fbKey = GlobalKey<FormBuilderState>();

  Future<void> sendMail(toEmail, data) async {
    String platformResponse;
    String body = "${"Hi, " +
        toEmail}, your new password for the Flutter Samples App is : " +
        data;

    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: toEmail,
        queryParameters: {
          'subject': 'Credentials for Samples App@NCNR',
          'body': body
        });

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
        platformResponse = "emailed";
      } else {
        throw 'Could not launch email';
      }
    } catch (error) {
      platformResponse = error.toString();
    }
    if (!mounted) return;

    toast(context, platformResponse, Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    if (exec) {
      try {
        _arch = (widget.user.archived == "0" ||
                widget.user.archived == "" ||
                widget.user.archived == null)
            ? false
            : true;
      } on Error {
        _arch = false;
      }
      try {
        _manager = (widget.user.manager == "0" ||
                widget.user.manager == "" ||
                widget.user.manager == null)
            ? false
            : true;
      } on Error {
        _manager = false;
      }

      // phone field with auto validate seems to be broken for FLutter 2.2
      // try {
      //   _phone = ((widget.user.phone == "" || widget.user.phone == null)
      //       ? ""
      //       : widget.user.phone)!;
      // } on Error {
      //   _phone = "";
      // }

      try {
        _address = ((widget.user.address == "" || widget.user.address == null)
            ? ""
            : widget.user.address)!;
      } on Error {
        _address = "";
      }
      try {
        _name = ((widget.user.name == "" || widget.user.name == null)
            ? ""
            : widget.user.name)!;
      } on Error {
        _name = "";
      }
      try {
        _email = ((widget.user.email == "" || widget.user.email == null)
            ? ""
            : widget.user.email)!;
      } on Error {
        _email = "";
      }
      try {
        _barcode = ((widget.user.barcode == "" || widget.user.barcode == null)
            ? ""
            : widget.user.barcode)!;
      } on Error {
        _barcode = "";
      }
      exec = false;
      //print(widget.user?.id); // null if a new user a value from the database if editing
    }

    return KeyboardActions(
        config: _buildConfig(context),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FormBuilder(
                  //context, ///this is the state that we store the form values.
                  key: _fbKey,
                  //autovalidateMode: AutovalidateMode.disabled,
                  initialValue: {
                    'barcode': _barcode,
                    'email': _email,
                    'password': _password,
                    'name': _name,
                    'manager': _manager,
                    'address': _address,
                    // 'phone': _phone,
                    'archived': _arch,
                  },
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        keyboardType: TextInputType.text,
                        focusNode: _nodeText1,
                        name: "name",
                        decoration: const InputDecoration(
                          labelText: "Name",
                          icon: Icon(MdiIcons.pirate),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),

                      FormBuilderTextField(
                        keyboardType: TextInputType.text,
                        focusNode: _nodeText2,
                        name: "email",
                        decoration: const InputDecoration(
                          labelText: "Email",
                          icon: Icon(MdiIcons.email),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),

                      // FormBuilderTextField(
                      //     keyboardType: TextInputType.text,
                      //     focusNode: _nodeText3,
                      //     name: "password",
                      //     readOnly: (widget.user.id == null ||
                      //             widget.user.id == "null" ||
                      //             widget.user.id == "")
                      //         ? false
                      //         : true,
                      //     decoration: InputDecoration(
                      //       labelText: "Passwd",
                      //       icon: Icon(MdiIcons.key),
                      //       enabled: (widget.user.id == null ||
                      //               widget.user.id == "null" ||
                      //               widget.user.id == "")
                      //           ? true
                      //           : false,
                      //     )),

                      FormBuilderTextField(
                        keyboardType: TextInputType.text,
                        focusNode: _nodeText4,
                        name: "address",
                        decoration: const InputDecoration(
                          labelText: "Address",
                          icon: Icon(MdiIcons.city),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // FormBuilderPhoneField(
                      //   keyboardType:
                      //       TextInputType.numberWithOptions(decimal: true),
                      //   focusNode: _nodeText5,
                      //   name: 'phone',
                      //   initialValue: "+240",
                      //   cursorColor: Colors.black,
                      //   // style: TextStyle(color: Colors.black, fontSize: 18),
                      //   decoration: InputDecoration(
                      //     border: OutlineInputBorder(),
                      //     labelText: "Phone Number",
                      //   ),
                      //   priorityListByIsoCode: ['US'],
                      //   validator: FormBuilderValidators.compose([
                      //     FormBuilderValidators.numeric(
                      //       context,
                      //       errorText: 'Invalid phone number',
                      //     ),
                      //   ]),
                      // ),

                      const SizedBox(height: 15),

                      FormBuilderSwitch(
                        title: const Text('Manager?'),
                        name: "manager",
                        initialValue: _manager,
                        decoration: const InputDecoration(
                          icon: Icon(MdiIcons.cardAccountDetailsStar,
                              color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderSwitch(
                        title: const Text('Archive this user?'),
                        name: "archived",
                        initialValue: _arch,
                        decoration: const InputDecoration(
                          icon: Icon(MdiIcons.trashCan, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 15),
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
                              /// an API call eventually.
                              child: ElevatedButton(
                                  onPressed: () {
                                    _fbKey.currentState?.validate();
                                    // try {
                                    if (widget.user.id != null ||
                                        widget.user.id != "null" ||
                                        widget.user.id == "") {
                                      // must be editing
                                      final container =
                                          MyInheritedWidget.of(context, false);
                                      var jwt = container.getjwt;
                                      // print('editing user');
                                      // print(widget.user.id);
                                      // var bc = (_fbKey.currentState!
                                      //     .fields['barcode']?.value);
                                      var bc =
                                          "User_${widget.user.id}";
                                      var em = (_fbKey.currentState!
                                          .fields['email']?.value);
                                      // var pw = (_fbKey.currentState!
                                      //     .fields['password']?.value);
                                      var nm = (_fbKey
                                          .currentState!.fields['name']?.value);
                                      var ad = (_fbKey.currentState!
                                          .fields['address']?.value);
                                      // var ph = (_fbKey.currentState!
                                      //     .fields['phone']?.value);
                                      var ma = "";
                                      var ar = "";
                                      _fbKey.currentState!.fields['manager']
                                              ?.value
                                          ? ma = "1"
                                          : ma = "0";
                                      _fbKey.currentState!.fields['archived']
                                              ?.value
                                          ? ar = "1"
                                          : ar = "0";
                                      final myFuture = API.updateUser(jwt,
                                          id: widget.user.id,
                                          //data: _fbKey.currentState!.value);
                                          data: {
                                            "barcode": bc,
                                            "email": em,
                                            "name": nm,
                                            "manager": ma,
                                            "address": ad,
                                            "phone": "+1-240", //ph,
                                            "archived": ar
                                          });
                                      myFuture.then((code) {
                                        if (code == "200") {
                                          toast(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              "Updated user: please refresh",
                                              Colors.green);
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(context);
                                        } else {
                                          // ignore: use_build_context_synchronously
                                          toast(context, "Error updating user!",
                                              Colors.red);
                                          // ignore: use_build_context_synchronously
                                          Navigator.pop(context);
                                        }
                                      });
                                    } else {
                                      toast(context, "Error updating user!",
                                          Colors.red);
                                      Navigator.pop(context);
                                      // }
                                    }

                                    //Navigator.of(context).pushNamed('/home');
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
                            )
                          ],
                        ),
                      ),
                      //SizedBox(height: 15),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Expanded(
                              /// Just navigate back on cancel.
                              child: ElevatedButton(
                                  onPressed: () {
                                    final container =
                                        MyInheritedWidget.of(context, false);
                                    var jwt = container.getjwt;

                                    var thisEmail = (_fbKey
                                        .currentState!.fields['email']?.value);
//                                     if (container.admin) {
//                                       var adminEmail = widget.user.email;
//                                     }
// NEED TO ADD:  take  care if a manager is resssetting an email. Add dropdown?

                                    final myFuture =
                                        API.updateUserPassword(jwt, thisEmail);
                                    myFuture.then((response) {
                                      if (response !=
                                              "error in password change" &&
                                          response != null) {
                                        toast(
                                            // ignore: use_build_context_synchronously
                                            context,
                                            "Updated password: sending email",
                                            Colors.green);

                                        // do something with the passsword
                                        print("PASSWORD: " + response);
                                        showDialog(
                                            // ignore: use_build_context_synchronously
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('New Password'),
                                                content: Text(
                                                    "${'${'Send password (' +
                                                        response}) to ' +
                                                        thisEmail}?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('No'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      sendMail(
                                                          thisEmail, response);
                                                    },
                                                    child: const Text('Yes'),
                                                  ),
                                                ],
                                              );
                                            });
                                      } else {
                                        toast(
                                            // ignore: use_build_context_synchronously
                                            context,
                                            "Error updating password!",
                                            Colors.red);
                                      }
                                    });
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
                                  child: const Text("Get a new password")),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
