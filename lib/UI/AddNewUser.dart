import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
// ignore: import_of_legacy_library_into_null_safe
//import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:string_validator/string_validator.dart';
import '../API.dart';
import '../main.dart';
import 'Toast.dart';
import 'package:url_launcher/url_launcher.dart';

class AddNewUser extends StatefulWidget {
  const AddNewUser({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _AddNewUserState createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
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

  final bool _manager = false; // init bool for manager or not
  //bool _arch = false; // init bool for archived or not
  // String _phone = "";
  final String _barcode = "";
  final String _email = "";
  final String _name = "";
  final String _address = "";
  final String _password = "";
  //var user = new User();
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
    //final container = MyInheritedWidget.of(context, false);

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
                    //'phone': _phone,
                    //'archived': _arch,
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

                      FormBuilderTextField(
                          keyboardType: TextInputType.text,
                          focusNode: _nodeText3,
                          name: "password",
                          decoration: const InputDecoration(
                            labelText: "Passwd",
                            icon: Icon(MdiIcons.key),
                          )),

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
                      // FormBuilderSwitch(
                      //   title: Text('Archive this user?'),
                      //   name: "archived",
                      //   initialValue: _arch,
                      //   decoration: InputDecoration(
                      //     icon: Icon(MdiIcons.trashCan, color: Colors.grey),
                      //   ),
                      // ),
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
                                    // must be a new user
                                    final container =
                                        MyInheritedWidget.of(context, false);
                                    var jwt = container.getjwt;
                                    // print('Adding a new user');
                                    var em = (_fbKey
                                        .currentState!.fields['email']?.value);
                                    var pw = (_fbKey.currentState!
                                        .fields['password']?.value);
                                    var nm = (_fbKey
                                        .currentState!.fields['name']?.value);
                                    var ad = (_fbKey.currentState!
                                        .fields['address']?.value);
                                    // var ph = (_fbKey
                                    //     .currentState!.fields['phone']?.value);
                                    var ma = "";
                                    //                                 var ar = "";
                                    _fbKey.currentState!.fields['manager']
                                            ?.value
                                        ? ma = "1"
                                        : ma = "0";
                                    // _fbKey.currentState!.fields['archived']
                                    //         ?.value
                                    //     ? ar = "1"
                                    //     : ar = "0";

                                    if (nm != "" &&
                                        isLength(nm, 4) &&
                                        em != "" &&
                                        isEmail(em)) {
                                      final myFuture =
                                          API.addNewUser(jwt, data: {
                                        "barcode": "",
                                        "email": em,
                                        "password": pw,
                                        "name": nm,
                                        "manager": ma,
                                        "address": ad,
                                        "phone": "+1-240", //ph,
                                        "archived": "0"
                                      });
                                      myFuture.then((code) {
                                        // print("code:" + code + "-");
                                        // ignore: use_build_context_synchronously
                                        FocusScope.of(context).unfocus();
                                        if (code.toString().toLowerCase() ==
                                            "error in adding new user: email already in database") {
                                          toast(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              "Error in adding new user: email already in database",
                                              Colors.red);
                                        } else if (code
                                                .toString()
                                                .toLowerCase() ==
                                            "error in adding new user: unknown error") {
                                          toast(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              "Error in adding new user: unknown error",
                                              Colors.red);
                                        } else if (code != "") {
                                          toast(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              "Added user: please refresh",
                                              Colors.green);

                                          // do something with the passsword
                                          showDialog(
                                              // ignore: use_build_context_synchronously
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      const Text('New User Password'),
                                                  content: Text(
                                                      '${'Send password (' +
                                                          code}) to user?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('No'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        sendMail(em, code);
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
                                              "Need Name and Email address",
                                              Colors.red);
                                          // toast(
                                          //     "Error adding user!", "red");
                                          // Navigator.pop(context);
                                        }
                                      });
                                    } else {
                                      toast(context, "Error updating user!",
                                          Colors.red);
                                    }

                                    //}
                                    // on Error {
                                    //   print('3');
                                    //   toast("Error updating user!", "red");
                                    //   Navigator.pop(context);
                                    // }
                                    // }

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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
