import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/Sample.dart';

/// import 'singlePrint.dart';
import 'EditPage.dart';
import 'ClonePage.dart';
import 'MovePage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../Functions/Server.dart'; // contains the $SERVER_IP address for all the app

/// This should show details of a given sample.
///
/// Seems that if I edit this sample, navigating back to this page, it will not be updated
/// since I do not actually edit this list.
/// options.  (1) have global sample list and edit that as well as POST
///           (2) Stateful widget - with a callback and POST
///           (3) Navigate home

// ignore: must_be_immutable
class DetailPage extends StatefulWidget {
  final Sample sample;

  const DetailPage({super.key, required this.sample});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final kExpandedHeight = 200.0;
  late Sample _currentSample;

  @override
  void initState() {
    super.initState();
    _currentSample = widget.sample;
  }

  void _launchURL() async => await canLaunchUrl(Uri.parse(
          '$SERVER_IP/sampletracking_test/sample_select.php?id=$id&room=$dropdownValue'))
      ? await launchUrl(
          Uri.parse(
              '$SERVER_IP/sampletracking_test/sample_select.php?id=$id&room=$dropdownValue'),
          mode: LaunchMode.externalApplication)
      : throw 'could not launch  $SERVER_IP/sampletracking_test/sample_select.php?id=$id&room=$dropdownValue';
  String dropdownValue = 'E131'; //initialize this

  get id => _currentSample.sampleId?.replaceAll(RegExp(r'^0+(?=.)'), '');
  bool dialVisible = true;

// made a seperate page to accommodate cases _launchURL doesnt work universally per OS.
  // void _launchWebView() {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               singlePrinterPage(id: id, printer: dropdownValue)));
  // }

  SpeedDial buildSpeedDial(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.edit, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () async {
            final updatedSample = await Navigator.push<Sample>(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(
                  sample: _currentSample,
                ),
              ),
            );
            if (updatedSample != null) {
              setState(() {
                _currentSample = updatedSample;
              });
              toast(context, "Sample updated successfully!", Colors.green);
            }
          },
          label: 'Edit',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: const Icon(Icons.train, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () async {
            final updatedSample = await Navigator.push<Sample>(
              context,
              MaterialPageRoute(
                builder: (context) => MovePage(
                  sample: _currentSample,
                ),
              ),
            );
            if (updatedSample != null) {
              setState(() {
                _currentSample = updatedSample;
              });
              toast(context, "Sample moved successfully!", Colors.green);
            }
          },
          label: 'Quick Edit',
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: const Icon(Icons.content_copy, color: Colors.white),
          backgroundColor: Colors.blue,
          onTap: () async {
            final newSample = await Navigator.push<Sample>(
              context,
              MaterialPageRoute(
                builder: (context) => ClonePage(
                  sample: _currentSample,
                ),
              ),
            );
            if (newSample != null) {
              // The clone page returns the new sample.
              // Replace the entire stack up to the list page with the new detail page.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(sample: newSample),
                ),
                (Route<dynamic> route) => route.isFirst, // This pops until the first route in the stack.
              );
            }
          },
          labelWidget: Container(
            color: Colors.blue,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(6),
            child: const Text('Copy as template'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Prepare hazard text separately for clarity and styling.
    final List<String> hazardStrings = [
      if (_currentSample.haz1 != null) _currentSample.haz1!,
      if (_currentSample.haz2 != null) _currentSample.haz2!,
      if (_currentSample.haz3 != null) _currentSample.haz3!,
      if (_currentSample.haz4 != null) _currentSample.haz4!,
    ];
    final String hazardText =
        hazardStrings.isNotEmpty ? 'Hazards: ${hazardStrings.join(', ')}' : '';

    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          leading: IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          expandedHeight: kExpandedHeight,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: _currentSample.imageURL.toString(),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/images/ncnr.jpg",
                    fit: BoxFit.cover,
                  ),
                  fit: BoxFit.cover,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: <Color>[
                        Colors.black54,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Adding the detailed text to the bottom of the background
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Chem: ${(_currentSample.chemical.toString())}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            shadows: [Shadow(blurRadius: 2.0)]),
                      ),
                      Text(
                        'ID: ${int.parse(_currentSample.sampleId.toString())}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                            shadows: [Shadow(blurRadius: 2.0)]),
                      ),
                      Text(
                        'Name: ${(_currentSample.sampleName.toString())}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            shadows: [Shadow(blurRadius: 2.0)]),
                      ),
                      if (hazardText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            hazardText,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 2.0)]),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            ListTile(
              leading: const ExcludeSemantics(
                child: Icon(Icons.local_library),
              ),
              title: const Text(
                'Owner:',
              ),
              subtitle:
                  Text('${_currentSample.owner} (${_currentSample.username})'),
            ),
            ListTile(
              leading: const ExcludeSemantics(
                child: Icon(Icons.child_friendly),
              ),
              title: const Text(
                'External User:',
              ),
              subtitle: Text(_currentSample.externalUser.toString()),
            ),
            ListTile(
              leading: const ExcludeSemantics(
                child: Icon(Icons.calendar_today),
              ),
              title: const Text(
                'Added on:',
              ),
              subtitle: Text(_currentSample.added.toString().substring(0, 10)),
            ),
            ListTile(
              leading: const ExcludeSemantics(
                child: Icon(Icons.gps_fixed),
              ),
              title: const Text(
                'Located:',
              ),
              subtitle: Text(_currentSample.locationString.toString()),
            ),
            ListTile(
              leading: const ExcludeSemantics(
                child: Icon(Icons.battery_full),
              ),
              title: const Text(
                'In cell:',
              ),
              subtitle: Text(_currentSample.cellbarcode.toString()),
            ),
            ListTile(
              leading: const ExcludeSemantics(
                child: Icon(Icons.fitness_center),
              ),
              title: const Text(
                'Mass:',
              ),
              subtitle: Text(_currentSample.quantity.toString() +
                  " " +
                  _currentSample.unit.toString() +
                  ' (' +
                  _currentSample.form.toString() +
                  ')'),
            ),
            ListTile(
              leading: const ExcludeSemantics(
                child: Icon(Icons.format_list_bulleted),
              ),
              title: const Text(
                'Notes:',
              ),
              subtitle: Text(_currentSample.extraNotes.toString()),
            ),
            //make a row to put dropdown and print button that will lead to munter's link
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Icon(Icons.print, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(5)),
                    //make dropdown shorter and no underline
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        hint: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Choose Location',
                          ),
                        ),
                        icon: const Icon(Icons.arrow_drop_down),
                        itemHeight: null,
                        style: const TextStyle(color: Colors.black),
                        underline: null,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: <String>['B128', 'B147', 'E131', 'G100']
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
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Print'),
                  onPressed: () {
                    if (defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.android) {
                      // _launchWebView();
                      _launchURL();
                    } else {
                      _launchURL(); // This was incase the OSX/Windows implementation did not get a web browsers.
                    }
                  },
                ),
              ],
            ),
          ]),
        ),
      ]),
      floatingActionButton: buildSpeedDial(context),
    );
  }
}
