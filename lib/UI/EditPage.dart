import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'EditContent.dart';
import 'EditContentWin.dart';
import '../models/Sample.dart';

class EditPage extends StatefulWidget {
  final Sample sample;

  const EditPage({super.key, required this.sample});

  @override
  EditPageState createState() => EditPageState();
}

class EditPageState extends State<EditPage> {
  String status = "edit";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Editing Sample ID: ${int.parse(widget.sample.sampleId!)}"),
        ),
        body: (defaultTargetPlatform != TargetPlatform.windows)
            ? EditContent(sample: widget.sample, status: status)
            : (defaultTargetPlatform == TargetPlatform.windows)
                ? EditContentWin(
                    sample: widget.sample,
                    status:
                        status) // could maybe have a future macOS page if cameras work
                : null);
  }
}
