import 'package:flutter/material.dart';
import '../models/Cells.dart';
import '../API.dart';
import '../main.dart';
import '../Functions/func.dart';
import 'dart:convert';
import 'CellsPage.dart';
import 'DetailPage.dart';

// ignore: must_be_immutable
class CellDetailPage extends StatelessWidget {
  final Cells cell;
  final kExpandedHeight = 200.0;
  bool noSampleIn = true;
  var localImage = "";
  var imageURL = "";

  CellDetailPage({super.key, required this.cell});

  @override
  Widget build(BuildContext context) {
    void getEmptyCells() {
      final container = MyInheritedWidget.of(context, false);
      container.clearEmptyCells();
      final myFuture = API.getEmptyCans(container.getjwt);
      myFuture.then((response) {
        if (response.statusCode == 200) {
          var eCells = List<Cells>.empty(growable: true);
          Iterable list = json.decode(response.body);
          eCells = list.map((model) => Cells.fromJson(model)).toList();

          // remove the archived ones:

          if (container.totalEmptyCells != eCells.length) {
            // has email list length changed or 1st running?
            container.clearEmptyCells(); // if so clear the list and repopulate
            for (var i = 0; i < eCells.length; i++) {
              if (eCells[i].archived == "0") {
                // ignore: use_build_context_synchronously
                addToEmptyCells(context: context, cell: eCells[i]);
              }
            }
          }
        }
      });
    }

    final container = MyInheritedWidget.of(context, false);

    if (cell.description == "Vanadium A") {
      localImage = "assets/images/V-cells.jpg";
    } else if (cell.description == "Vanadium B") {
      localImage = "assets/images/V-cells.jpg";
    } else if (cell.description == "Vanadium C") {
      localImage = "assets/images/V-cells.jpg";
    } else if (cell.description == "Vanadium D") {
      localImage = "assets/images/V-cells.jpg";
    } else if (cell.description == "Vanadium E") {
      localImage = "assets/images/V-cells.jpg";
    } else if (cell.description == "Brookhaven SC") {
      localImage = "assets/images/Brookhaven.jpg";
    } else if (cell.description == "Al 6.3cc") {
      localImage = "assets/images/Al-cans.jpg";
    } else if (cell.description == "Al 3.1cc") {
      localImage = "assets/images/Al-cans.jpg";
    } else if (cell.description == "Al 1.6cc") {
      localImage = "assets/images/Al-cans.jpg";
    } else if (cell.description == "Al 1.2cc") {
      localImage = "assets/images/Al-cans.jpg";
    } else if (cell.description == "DCS Al") {
      localImage = "assets/images/dcs-can.jpg";
    } else if (cell.description == "Single Crystal Small") {
      localImage = "assets/images/Brookhaven.jpg";
    } else if (cell.description == "Single Crystal Large") {
      localImage = "assets/images/Brookhaven.jpg";
    } else {
      localImage = "assets/images/ncnr.jpg";
    }

    try {
      // ignore: unnecessary_null_comparison
      if (cell.sample?.sampleId != null && cell.sample?.sampleId != "") {
        noSampleIn = false;
        imageURL = cell.sample!.imageURL!;
      }
    } on Error {
      noSampleIn = true;
    }

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
          //title:  Text( '_SliverAppBar')  ,
          flexibleSpace: FlexibleSpaceBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Barcode: ${cell.barcode!}',
                  style: const TextStyle(color: Colors.white, fontSize: 8.0),
                ),
                Text(
                  cell.description!,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ],
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                (imageURL != "")
                    ? Image.network(
                        cell.sample!.imageURL!,
                        fit: BoxFit.scaleDown,
                      )
                    : Image.asset(
                        localImage,
                        fit: BoxFit.cover,
                      ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.0, 0.7),
                      end: Alignment(0.0, 0.3),
                      colors: <Color>[
                        Color(0x60000000),
                        Color(0x00000000),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        noSampleIn
            ? SliverList(
                delegate: SliverChildListDelegate([
                  //Text("No sample currently in this cell"),

                  Container(
                    margin: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('No sample currently in this cell',
                            style: TextStyle(fontSize: 22)),
                        //_buildName(),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          child: const Text('Delete Cell'),
                          onPressed: () {
                            final myFuture =
                                API.deleteCell(container.getjwt, cell.id);
                            myFuture.then((response) {
                              if (response == 200) {
                                print('Deleted Cell');
                                getEmptyCells();
                                Navigator.push(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const CellsPage()));
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  )
                ]),
              )
            : SliverList(
                delegate: SliverChildListDelegate([
                  ListTile(
                    leading: const ExcludeSemantics(
                      child: Icon(Icons.check_circle),
                    ),
                    title: const Text(
                      'Chemical:',
                    ),
                    subtitle: Text('${cell.sample!.chemical!} (${cell.sample!.sampleName!})'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(sample: cell.sample!)));
                    },
                  ),
                  ListTile(
                    leading: const ExcludeSemantics(
                      child: Icon(Icons.local_library),
                    ),
                    title: const Text(
                      'Owner:',
                    ),
                    subtitle: Text('${cell.sample!.owner!} (${cell.sample!.username!})'),
                  ),
                  ListTile(
                    leading: const ExcludeSemantics(
                      child: Icon(Icons.child_friendly),
                    ),
                    title: const Text(
                      'External User:',
                    ),
                    subtitle: Text(cell.sample!.externalUser!),
                  ),
                  ListTile(
                    leading: const ExcludeSemantics(
                      child: Icon(Icons.calendar_today),
                    ),
                    title: const Text(
                      'Added on:',
                    ),
                    subtitle: Text(cell.sample!.added!.substring(0, 10)),
                  ),
                  ListTile(
                    leading: const ExcludeSemantics(
                      child: Icon(Icons.gps_fixed),
                    ),
                    title: const Text(
                      'Located:',
                    ),
                    subtitle: Text(cell.sample!.locationString!),
                  ),
                  ListTile(
                    leading: const ExcludeSemantics(
                      child: Icon(Icons.fitness_center),
                    ),
                    title: const Text(
                      'Mass:',
                    ),
                    subtitle: Text(cell.sample!.quantity! +
                        " " +
                        cell.sample!.unit! +
                        ' (' +
                        cell.sample!.form! +
                        ')'),
                  ),
                  ListTile(
                    leading: const ExcludeSemantics(
                      child: Icon(Icons.format_list_bulleted),
                    ),
                    title: const Text(
                      'Notes:',
                    ),
                    subtitle: Text(cell.sample!.extraNotes!),
                  ),
                ]),
              ),
      ]),
    );
  }
}
