import 'package:flutter/material.dart';
import 'data.dart';
//import '../API.dart';

//Creates cascading dropdowns for location
class DropDown {
  // ignore: prefer_typing_uninitialized_variables
  var parentLocation;
  // ignore: prefer_typing_uninitialized_variables
  var isVisible;
  String? dropdownValue;

  DropDown({parent, vis, String? value}) {
    parentLocation = parent;
    isVisible = vis;
    dropdownValue = value;
  }
}

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Locations(),
    );
  }
}

class Locations extends StatefulWidget {
  const Locations({super.key});

  @override
  State<Locations> createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  int _dropDownNumber = 0;

  final List<DropDown> _allDropDowns = [
    DropDown(parent: locationOptionsConf, vis: true, value: null),
    DropDown(parent: locationOptionsConf, vis: false, value: null),
    DropDown(parent: locationOptionsConf, vis: false, value: null),
    DropDown(parent: locationOptionsConf, vis: false, value: null),
  ];

  buildDropDown(int num) {
    return Visibility(
      visible: _allDropDowns[num].isVisible as bool,
      child: DropdownButtonFormField(
        value: _allDropDowns[num].dropdownValue,
        validator: (value) {
          if (value == null) {
            return 'Please enter some text';
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            _allDropDowns[num].dropdownValue = newValue;
            nextDropDown(_allDropDowns[num].dropdownValue);
          });
        },
        items: _allDropDowns[num]
            .parentLocation
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                value,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget nextDropDown(String? value) {
    _dropDownNumber++; //replace,  need to track which dropdown is providing the value in order to make the next one
    _allDropDowns[_dropDownNumber].isVisible = true;
    _allDropDowns[_dropDownNumber].parentLocation =
        placeOptions; //replace placeOptions with api call, use value to get id to get child locations for that value id
    return buildDropDown(_dropDownNumber);
  }

  Widget hideDropDown() {
    //to be used to hide the following dropdowns if someone goes back to change the value of a previous dropdown
    //currently if someone goes back to change a previous dropdown, a new dropdown will still be added
    //using _dropDownNumber won't work, see above
    _allDropDowns[_dropDownNumber].isVisible = false;
    return buildDropDown(_dropDownNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildDropDown(0),
                    buildDropDown(1),
                    buildDropDown(2),
                    buildDropDown(3),
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
