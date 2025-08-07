// Flutter samples
// Package has been updates to work with Flutter 3.04 and dependent packages in YAML
// Sound-null-safety is now included in all packages and this codebase
//
// Compile usisng the "flutter build/run" commands
//
// dependencies Use: "flutter pub get" if not automatically downloaded by IDE
// (A 'flutter clen' can help fix a broken pub or cache)
//

import 'package:flutter/material.dart';
import 'dart:io';

/// local app files
import 'Login.dart';
import 'ListPage.dart';
import 'models/Cells.dart';
import 'models/Sample.dart';
import 'UI/CellsPage.dart';
import 'UI/EmptyPage.dart';
// import 'UI/ScanPage.dart';
import 'UI/ScannerPage.dart';
import 'UI/ScannerWinPage.dart';
import 'UI/UsersPage.dart';
import 'UI/AllPage.dart';
import 'UI/Printer.dart';
import 'UI/about.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyInheritedWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Samples',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(158, 166, 186, 1.0),
        ),
      ),
      home:  const Login(),
      initialRoute: '/',
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) =>
              const Scaffold(body: Center(child: Text('Not Found'))),
        );
      },
      routes: {
        /// Only load your samples by default
        '/myhome': (BuildContext context) => const ListPage(),

        /// List all cells w/ appropriatecontents Can add cells.
        '/cells': (BuildContext context) => const CellsPage(),

        /// Quickly empty cells for Admin
        '/empty': (BuildContext context) => const EmptyPage(),

        /// Get all samples if Admin user
        '/all': (BuildContext context) => const AllPage(),

        /// might not need
        '/scan': (BuildContext context) => const ScannerPage(),
        // '/scan': (BuildContext context) => ScanPage(),

        '/scanWin': (BuildContext context) => const ScannerWinPage(),

        // Printer page
        '/printers': (BuildContext context) => const PrinterPage(),

        /// about page
        '/about': (BuildContext context) => const AboutPage(),

        '/users': (BuildContext context) => const UsersPage(),
      },
    );
  }
}
//------------------- inherited widgets to pass around info -------//

class _MyInherited extends InheritedWidget {
  // Data is your entire state.
  final MyInheritedWidgetState data;

  // You must pass through a child and your state.
  const _MyInherited({
    required super.child,
    required this.data,
  });

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_MyInherited oldWidget) {
    return true;
  }
}

class MyInheritedWidget extends StatefulWidget {
  // You must pass through a child.
  final Widget child;

  const MyInheritedWidget({
    super.key,
    required this.child,
  });

  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static MyInheritedWidgetState of(
      [BuildContext? context, bool rebuild = true]) {
    return (rebuild
        ? context!.dependOnInheritedWidgetOfExactType<_MyInherited>()!.data
        : context!.findAncestorWidgetOfExactType<_MyInherited>()!.data);
  }

  @override
  MyInheritedWidgetState createState() => MyInheritedWidgetState();
}

class MyInheritedWidgetState extends State<MyInheritedWidget> {
  /// List of user's emails:names
  List<String> _emails = <String>[];
  List<String> _usernames = <String>[];

  String _place = '';
  String _location = '';
  String _locationid = '';
  String _drawer = '';

// array of multiseleted samples that are acted upon
  var _editSamples = List<Sample>.empty(growable: true);

  final List<String> _cells = <String>[
    "Vanadium A",
    "Vanadium B",
    "Vanadium C",
    "Vanadium D",
    "Vanadium E",
    "Brookhaven SC",
    "Single Crystal Small",
    "Single Crystal Large",
    "Al 6.3cc",
    "Al 3.1cc",
    "Al 1.6cc",
    "Al 1.2cc",
    "DCS Al",
    "a generic cell"
  ];

  var _fullVanA = List<Cells>.empty(growable: true);
  var _emptyVanA = List<Cells>.empty(growable: true);
  var _fullVanB = List<Cells>.empty(growable: true);
  var _emptyVanB = List<Cells>.empty(growable: true);
  var _fullVanC = List<Cells>.empty(growable: true);
  var _emptyVanC = List<Cells>.empty(growable: true);
  var _fullVanD = List<Cells>.empty(growable: true);
  var _emptyVanD = List<Cells>.empty(growable: true);
  var _fullVanE = List<Cells>.empty(growable: true);
  var _emptyVanE = List<Cells>.empty(growable: true);
  var _fullAl12 = List<Cells>.empty(growable: true);
  var _emptyAl12 = List<Cells>.empty(growable: true);
  var _fullAl16 = List<Cells>.empty(growable: true);
  var _emptyAl16 = List<Cells>.empty(growable: true);
  var _fullAl31 = List<Cells>.empty(growable: true);
  var _emptyAl31 = List<Cells>.empty(growable: true);
  var _fullAl63 = List<Cells>.empty(growable: true);
  var _emptyAl63 = List<Cells>.empty(growable: true);
  var _fullDCS = List<Cells>.empty(growable: true);
  var _emptyDCS = List<Cells>.empty(growable: true);
  var _fullSS = List<Cells>.empty(growable: true);
  var _emptySS = List<Cells>.empty(growable: true);
  var _fullBrookhaven = List<Cells>.empty(growable: true);
  var _emptyBrookhaven = List<Cells>.empty(growable: true);
  var _fullOther = List<Cells>.empty(growable: true);
  var _emptyOther = List<Cells>.empty(growable: true);
  int totalFullCells = 0;
  int totalEmptyCells = 0;

// Form and Units
  List<dynamic> _forms = [];
  List<dynamic> _units = [];
  List<dynamic> _hazards = [];

  // just current user
  int _index = -1;
  bool _admin = false;
  String _myName = "";
  String _myEmail = "";
  String _myJwt = "";

  /// Getter for samples to be edited
  List get toEditSamples => _editSamples;

  /// Getters for form,hazards, and units
  List get sampleForms => _forms;
  List get sampleUnits => _units;
  List get sampleHazards => _hazards;

  /// location Getters
  String get place => _place;
  String get location => _location;
  String get locationid => _locationid;
  String get drawer => _drawer;

  /// Getters for cells
  List get cellTypes => _cells;
  List get eVanAList => _emptyVanA;
  List get fVanAList => _fullVanA;
  List get eVanBList => _emptyVanB;
  List get fVanBList => _fullVanB;
  List get eVanCList => _emptyVanC;
  List get fVanCList => _fullVanC;
  List get eVanDList => _emptyVanD;
  List get fVanDList => _fullVanD;
  List get eVanEList => _emptyVanE;
  List get fVanEList => _fullVanE;

  List get eAl12List => _emptyAl12;
  List get fAl12List => _fullAl12;
  List get eAl16List => _emptyAl16;
  List get fAl16List => _fullAl16;
  List get eAl31List => _emptyAl31;
  List get fAl31List => _fullAl31;
  List get eAl63List => _emptyAl63;
  List get fAl63List => _fullAl63;
  List get eDCSList => _emptyDCS;
  List get fDCSList => _fullDCS;
  List get eSSList => _emptySS;
  List get fSSList => _fullSS;
  List get eBrookhavenEList => _emptyBrookhaven;
  List get fBrookhavenEList => _fullBrookhaven;
  List get eOtherList => _emptyOther;
  List get fOtherList => _fullOther;
  int get totalFull => totalFullCells;
  int get totalEmpty => totalEmptyCells;

// All users - Handy for Admins to assign samples to
  List get emailList => _emails;
  List get userList => _usernames;

  //Logged in user
  int get userIndex => _index;
  bool get admin => _admin;
  String get userName => _myName;
  String get userEmail => _myEmail;
  String get getjwt => _myJwt;

  /// method to add editable samples
  void addSamplesToEdit(Sample reference) {
    _editSamples.add(reference);
  }

  /// method to clear editable samples
  void deleteSamplesToEdit() {
    _editSamples = [];
  }

  /// method to delete editable samples for an index
  void deleteSamplesToEditAtID(index) {
    _editSamples.removeAt(index);
  }

  /// Helper method to add forms, hazards and units
  void addForm(String reference) {
    _forms.add(reference);
  }

  /// Helper method to add forms, hazards and units
  void clearForm() {
    _forms = [];
  }

  void addHaz(String reference) {
    _hazards.add(reference);
  }

  void clearHaz() {
    _hazards = [];
  }

  void addUnit(String reference) {
    _units.add(reference);
  }

  void clearUnit() {
    _units = [];
  }

  /// Helper method to add cell
  void addFullVanA(Cells reference) {
    _fullVanA.add(reference);
    totalFullCells++;
  }

  void addEmptyVanA(Cells reference) {
    _emptyVanA.add(reference);
    totalEmptyCells++;
  }

  void addFullVanB(Cells reference) {
    _fullVanB.add(reference);
    totalFullCells++;
  }

  void addEmptyVanB(Cells reference) {
    _emptyVanB.add(reference);
    totalEmptyCells++;
  }

  void addFullVanC(Cells reference) {
    _fullVanC.add(reference);
    totalFullCells++;
  }

  void addEmptyVanC(Cells reference) {
    _emptyVanC.add(reference);
    totalEmptyCells++;
  }

  void addFullVanD(Cells reference) {
    _fullVanD.add(reference);
    totalFullCells++;
  }

  void addEmptyVanD(Cells reference) {
    _emptyVanD.add(reference);
    totalEmptyCells++;
  }

  void addFullVanE(Cells reference) {
    _fullVanE.add(reference);
    totalFullCells++;
  }

  void addEmptyVanE(Cells reference) {
    _emptyVanE.add(reference);
    totalEmptyCells++;
  }

  void addFullAl12(Cells reference) {
    _fullAl12.add(reference);
    totalFullCells++;
  }

  void addEmptyAl12(Cells reference) {
    _emptyAl12.add(reference);
    totalEmptyCells++;
  }

  void addFullAl16(Cells reference) {
    _fullAl16.add(reference);
    totalFullCells++;
  }

  void addEmptyAl16(Cells reference) {
    _emptyAl16.add(reference);
    totalEmptyCells++;
  }

  void addFullAl31(Cells reference) {
    _fullAl31.add(reference);
    totalFullCells++;
  }

  void addEmptyAl31(Cells reference) {
    _emptyAl31.add(reference);
    totalEmptyCells++;
  }

  void addFullAl63(Cells reference) {
    _fullAl63.add(reference);
    totalFullCells++;
  }

  void addEmptyAl63(Cells reference) {
    _emptyAl63.add(reference);
    totalEmptyCells++;
  }

  void addFullDCS(Cells reference) {
    _fullDCS.add(reference);
    totalFullCells++;
  }

  void addEmptyDCS(Cells reference) {
    _emptyDCS.add(reference);
    totalEmptyCells++;
  }

  void addFullSS(Cells reference) {
    _fullSS.add(reference);
    totalFullCells++;
  }

  void addEmptySS(Cells reference) {
    _emptySS.add(reference);
    totalEmptyCells++;
  }

  void addFullBrookhaven(Cells reference) {
    _fullBrookhaven.add(reference);
    totalFullCells++;
  }

  void addEmptyBrookhaven(Cells reference) {
    _emptyBrookhaven.add(reference);
    totalEmptyCells++;
  }

  void addFullOther(Cells reference) {
    _fullOther.add(reference);
    totalFullCells++;
  }

  void addEmptyOther(Cells reference) {
    _emptyOther.add(reference);
    totalEmptyCells++;
  }

  /// Helper method to clear cell list
  void clearFullCells() {
    _fullVanA = [];
    _fullVanB = [];
    _fullVanC = [];
    _fullVanD = [];
    _fullVanE = [];
    _fullAl12 = [];
    _fullAl16 = [];
    _fullAl31 = [];
    _fullAl63 = [];
    _fullDCS = [];
    _fullSS = [];
    _fullBrookhaven = [];
    _fullOther = [];
    totalFullCells = 0;
  }

  void clearEmptyCells() {
    _emptyVanA = [];
    _emptyVanB = [];
    _emptyVanC = [];
    _emptyVanD = [];
    _emptyVanE = [];
    _emptyAl12 = [];
    _emptyAl16 = [];
    _emptyAl31 = [];
    _emptyAl63 = [];
    _emptyDCS = [];
    _emptySS = [];
    _emptyBrookhaven = [];
    _emptyOther = [];
    totalEmptyCells = 0;
  }

  /// Helper method to add an Email to the List
  void addEmail(String reference) {
    setState(() {
      _emails.add(reference.toString());
    });
  }

  /// Helper method to clear email list
  void clearEmails() {
    setState(() {
      _emails = [];
    });
  }

  /// Helper method to clear username list
  void clearUsers() {
    setState(() {
      _usernames = [];
    });
  }

  /// Helper method to add a username to the List
  void addUserName(String reference) {
    setState(() {
      _usernames.add(reference.toString());
    });
  }

  /// Helper method to add logged in user
  void setUser(String reference) {
    setState(() {
      _myName = reference;
    });
  }

  /// Helper method to add a email for logged in user
  void setEmail(String reference) {
    setState(() {
      _myEmail = reference;
    });
  }

  /// Helper method to add a jwt for logged in user
  void setJwt(String reference) {
    setState(() {
      _myJwt = reference;
    });
  }

  /// Helper method to add a admin state to the List
  void setAdmin(bool reference) {
    //print('setting admin ' + reference.toString());
    setState(() {
      _admin = reference;
    });
  }

  /// Helper method to add the index for logged in user in  user/email List
  void setIndex(int reference) {
    setState(() {
      _index = reference;
    });
  }

  /// Helper method to add a email for logged in user
  void setPlace(String reference) {
    setState(() {
      _place = reference;
    });
  }

  /// Helper method to add a email for logged in user
  void setLocation(String reference) {
    setState(() {
      _location = reference;
    });
  }

  /// Helper method to add a email for logged in user
  void setLocationid(String reference) {
    setState(() {
      _locationid = reference;
    });
  }

  /// Helper method to add a email for logged in user
  void setDrawer(String reference) {
    setState(() {
      _drawer = reference;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MyInherited(
      data: this,
      child: widget.child,
    );
  }
}

//------------------- End of inherited widgets to pass around info -------//
