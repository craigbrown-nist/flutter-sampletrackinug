import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'EditContent.dart';
import 'EditContentWin.dart';
import '../models/Sample.dart';

class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  NewPageState createState() => NewPageState();
}

class NewPageState extends State<NewPage> {
  String status = "edit";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Editing a new sample"),
        ),
        body: (defaultTargetPlatform != TargetPlatform.windows)
            ? EditContent(sample: Sample(), status: "new")
            : (defaultTargetPlatform == TargetPlatform.windows)
                ? EditContentWin(
                    sample: Sample(),
                    status:
                        "new") // what about macos cameras just disable button on adding?
                : null);
  }
}
