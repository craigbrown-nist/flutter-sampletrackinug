import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'data.dart';
import '../API.dart';
//import '../models/Sample.dart';

class MyMoveDialog extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final keep; // pass this from the parent widget if you do not want to delete
  // the inherited widgets samples to edit array

  const MyMoveDialog({super.key, this.keep});

  @override
  // ignore: library_private_types_in_public_api
  _MyMoveDialogState createState() => _MyMoveDialogState();
}

class _MyMoveDialogState extends State<MyMoveDialog> {
  bool exec = true;
  String place = "";
  String location = "";
  List locationList = [];
  String locationid = "";
  List locationidList = [];
  String drawer = "";
  List drawerList = [];

  @override
  dispose() {
    super.dispose();
  }

  void setPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('place', place);
    prefs.setString('location', location);
    prefs.setString('locationid', locationid);
    prefs.setString('drawer', drawer);
    // ignore: use_build_context_synchronously
    final container = MyInheritedWidget.of(context, false);
    container.setPlace(place);
    container.setLocation(location);
    container.setLocationid(locationid);
    container.setDrawer(drawer);
  }

  @override
  Widget build(BuildContext context) {
    final container = MyInheritedWidget.of(context, false);

    if (exec) {
      // get the places/loc/id/drawer if they exist in the widget.
      if (place == '' && container.place != '') {
        place = container.place;
        location = container.location;
        locationid = container.locationid;
        drawer = container.drawer;
      } else {
        place = "Confinement";
        location = "BT1";
        locationid = "Bank 16";
        drawer = "2";
      }

      if (place == 'Confinement') {
        locationList = locationOptionsConf;
      } else if (place == 'GuideHall') {
        locationList = locationOptionsGuide;
      } else if (place == 'Lab') {
        locationList = locationOptionsLab;
      } else {
        locationList = locationOptionsOther;
      }

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
                // ignore: unnecessary_statements
                widget.keep ? null : container.deleteSamplesToEdit();
                Navigator.of(context).pop();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.close),
              ),
            ),
          ),
          Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("Choose location of samples"),
                // ignore: avoid_unnecessary_containers
                Container(
                  child: Row(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                      ),
                      Flexible(
                        child: DropdownButton<String>(
                          value: place,
                          isExpanded: true,
                          hint: const Text('Place'),
                          underline: Container(
                            height: 1,
                            color: Colors.blue,
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              place = newValue!;
                              //empty other values
                              location = '';
                              locationList = [];
                              locationid = '';
                              locationidList = [];
                              drawer = '';
                              drawerList = [];
                              // get new values for next list
                              if (place == 'Confinement') {
                                locationList = locationOptionsConf;
                              } else if (place == 'GuideHall') {
                                locationList = locationOptionsGuide;
                              } else if (place == 'Lab') {
                                locationList = locationOptionsLab;
                              } else {
                                locationList = locationOptionsOther;
                              }
                              // set the first items as default
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
                              // set the first item as default
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
                              } else if (locationid == 'Freezer4-Right') {
                                drawerList = drawer4;
                              } else if (locationid == 'Fridge-Left') {
                                drawerList = drawer6;
                              } else if (locationid == 'Fridge-Right') {
                                drawerList = drawer6;
                              } else {
                                drawerList = [""];
                              }
                              drawer = drawerList[0];
                              // get new values for next list
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
                              } else if (locationid == 'Freezer4-Right') {
                                drawerList = drawer4;
                              } else if (locationid == 'Fridge-Left') {
                                drawerList = drawer6;
                              } else if (locationid == 'Fridge-Right') {
                                drawerList = drawer6;
                              } else {
                                drawerList = [""];
                              }
                              drawer = drawerList[0];
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
                                } else if (locationid == 'Freezer4-Right') {
                                  drawerList = drawer4;
                                } else if (locationid == 'Fridge-Left') {
                                  drawerList = drawer6;
                                } else if (locationid == 'Fridge-Right') {
                                  drawerList = drawer6;
                                } else {
                                  drawerList = [""];
                                }
                                drawer = drawerList[0];
                                // set the first item as default
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
                                //empty other values
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
                                } else if (locationid == 'Freezer4-Right') {
                                  drawerList = drawer4;
                                } else if (locationid == 'Fridge-Left') {
                                  drawerList = drawer6;
                                } else if (locationid == 'Fridge-Right') {
                                  drawerList = drawer6;
                                } else {
                                  drawerList = [""];
                                }
                                // set the first item as default
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

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setPrefs();
                      for (var i = 0; i < container.toEditSamples.length; i++) {
                        // edit locations of these samples

                        container.toEditSamples[i].date =
                            DateFormat('yyyy-MM-dd')
                                .format(DateTime.now());

                        container.toEditSamples[i].sampleId =
                            (int.parse(container.toEditSamples[i].sampleId)
                                .toString());

                        container.toEditSamples[i].place = place;
                        container.toEditSamples[i].location = location;
                        container.toEditSamples[i].locationid = locationid;
                        container.toEditSamples[i].drawer = drawer;
                        // container.toEditSamples[i].form = 'Single Crystal';

                        print("Moved to: $place, $location, $locationid, $drawer");
                        //! The below is not implementted on server side  -
                        //! might want to add a 'who edited me' such as the user email

                        container.toEditSamples[i].parent = "0";

                        //update
                        final myFuture = API.updateSample(container.getjwt,
                            sample: container.toEditSamples[i]);
                        // print(container.toEditSamples[i].sampleId);
                        myFuture.then((response) {
                          if (response != null) {
                            print('sample  edited');
                            if (i == container.toEditSamples.length - 1) {
                              widget.keep
                                  // ignore: unnecessary_statements
                                  ? null
                                  : container.deleteSamplesToEdit();
                              // ignore: use_build_context_synchronously
                              Navigator.of(context, rootNavigator: true)
                                  .pop('Moved');
                            }
                          } else {
                            print('Error Moving');
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Move Selected Samples",
                        style: TextStyle(color: Colors.white)),
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
