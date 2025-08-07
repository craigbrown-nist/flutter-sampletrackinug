import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'EditContentWin.dart';

import 'EditContent.dart';
import '../models/Sample.dart';

class ClonePage extends StatefulWidget {
  final Sample sample;

  const ClonePage({super.key, required this.sample});

  @override
  ClonePageState createState() => ClonePageState();
}

class ClonePageState extends State<ClonePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a new sample from a template"),
      ),
      body: (defaultTargetPlatform != TargetPlatform.windows)
          ? EditContent(sample: widget.sample, status: 'clone')
          : EditContentWin(sample: widget.sample, status: 'clone'),
    );
  }
}
