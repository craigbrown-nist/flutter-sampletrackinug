import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../main.dart';
//import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../Functions/Server.dart';

// The widgets in this file are composed of 2 sections , each with 2 sections:
// Are you Admin or User?
//      and for each of those
// is this a phone (and can launch a webview) or
//         a desktop (that needs to open a browser)?
//
// it can be probably programatically simplified, but is also straightforward
// to read the way I did it here.

void logout(context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final container = MyInheritedWidget.of(context, false);

  //print(prefs.getString('jwt'));
  prefs.setString('datauser', "");
  prefs.setBool('isLoggedIn', false);
  prefs.setString('jwt', "");
  print('resetting preferences');
  print(prefs.getString('jwt'));


    container.setJwt('');
    container.setEmail("");
    container.setAdmin(false);
    container.setIndex(-1);
    container.deleteSamplesToEdit;
    container.setUser("");
    container.clearEmails();
    container.clearUsers();


  Navigator.pushReplacementNamed(context, '/');
}

_launchURL() async {
  // ignore: no_leading_underscores_for_local_identifiers
  final Uri _url = Uri.parse('$SERVER_IP/sampletracking_test/samples_b147.php');
  if (!await launchUrl(_url)) throw 'Could not launch $_url';
}

adminNavDrawer(BuildContext context) {
  final container = MyInheritedWidget.of(context, false);
  if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
                color: Color.fromRGBO(158, 166, 186, 1.0),
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/ncnr.jpg'))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ignore: avoid_unnecessary_containers
                Container(
                  child: const Text(
                    "Menu",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 55,
                        shadows: [
                          Shadow(
                              // bottomLeft
                              offset: Offset(-1.5, -1.5),
                              color: Colors.white),
                          Shadow(
                              // bottomRight
                              offset: Offset(1.5, -1.5),
                              color: Colors.white),
                          Shadow(
                              // topRight
                              offset: Offset(1.5, 1.5),
                              color: Colors.white),
                          Shadow(
                              // topLeft
                              offset: Offset(-1.5, 1.5),
                              color: Colors.white),
                        ]),
                  ),
                ),
                const Spacer(),
                // ignore: avoid_unnecessary_containers
                Container(
//                alignment: Alignment.bottomRight,
                  child: Text(
                    container.userName,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
              leading: const Icon(Icons.local_library),
              title: const Text('My samples'),
              onTap: () {
                Navigator.of(context).pushNamed('/myhome');
              }),
          ListTile(
              leading: const Icon(Icons.settings_input_composite),
              title: const Text('Cells'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/cells');
              }),
          ListTile(
              leading: const Icon(MdiIcons.qrcode),
              title: const Text('Scan'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/scan');
              }),
          ListTile(
              leading: const Icon(Icons.face),
              title: const Text('users'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/users');
              }),
          ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('All Samples'),
              onTap: () {
                Navigator.of(context).pushNamed('/all');
              }),
          ListTile(
              leading: const Icon(Icons.autorenew),
              title: const Text('To Empty'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/empty');
              }),
          ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Printers'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/printers');
              }),
          ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/about');
              }),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              logout(context);
              //Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  } else {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
                color: Color.fromRGBO(158, 166, 186, 1.0),
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/ncnr.jpg'))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ignore: avoid_unnecessary_containers
                Container(
                  child: const Text(
                    "Menu",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 55,
                        shadows: [
                          Shadow(
                              // bottomLeft
                              offset: Offset(-1.5, -1.5),
                              color: Colors.white),
                          Shadow(
                              // bottomRight
                              offset: Offset(1.5, -1.5),
                              color: Colors.white),
                          Shadow(
                              // topRight
                              offset: Offset(1.5, 1.5),
                              color: Colors.white),
                          Shadow(
                              // topLeft
                              offset: Offset(-1.5, 1.5),
                              color: Colors.white),
                        ]),
                  ),
                ),
                const Spacer(),
                // ignore: avoid_unnecessary_containers
                Container(
//                alignment: Alignment.bottomRight,
                  child: Text(
                    container.userName,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
              leading: const Icon(Icons.local_library),
              title: const Text('My samples'),
              onTap: () {
                Navigator.of(context).pushNamed('/myhome');
              }),
          ListTile(
              leading: const Icon(MdiIcons.qrcode),
              title: const Text('Scan'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/scanWin');
              }),
          ListTile(
              leading: const Icon(Icons.settings_input_composite),
              title: const Text('Cells'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/cells');
              }),
          ListTile(
              leading: const Icon(Icons.face),
              title: const Text('users'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/users');
              }),
          ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('All Samples'),
              onTap: () {
                Navigator.of(context).pushNamed('/all');
              }),
          ListTile(
              leading: const Icon(Icons.autorenew),
              title: const Text('To Empty'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/empty');
              }),
          ListTile(
              leading: const Icon(Icons.settings_input_composite),
              title: const Text('Web Print'),
              onTap: () {
                _launchURL();
              }),
          ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/about');
              }),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              logout(context);
              //Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}

userNavDrawer(BuildContext context) {
  if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Color.fromRGBO(158, 166, 186, 1.0),
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/ncnr.jpg'))),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 35),
            ),
          ),
          ListTile(
              leading: const Icon(Icons.local_library),
              title: const Text('My samples'),
              onTap: () {
                Navigator.of(context).pushNamed('/myhome');
              }),
          ListTile(
              leading: const Icon(Icons.settings_input_composite),
              title: const Text('Cells'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/cells');
              }),
          ListTile(
              leading: const Icon(MdiIcons.qrcode),
              title: const Text('Scan'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/scan');
              }),
          ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Printers'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/printers');
              }),
          ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/about');
              }),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  } else {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Color.fromRGBO(158, 166, 186, 1.0),
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/ncnr.jpg'))),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 35),
            ),
          ),
          ListTile(
              leading: const Icon(Icons.local_library),
              title: const Text('My samples'),
              onTap: () {
                Navigator.of(context).pushNamed('/myhome');
              }),
          ListTile(
              leading: const Icon(Icons.settings_input_composite),
              title: const Text('Cells'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/cells');
              }),
          ListTile(
              leading: const Icon(Icons.settings_input_composite),
              title: const Text('Web Print'),
              onTap: () {
                _launchURL();
              }),
          ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/about');
              }),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }
}
