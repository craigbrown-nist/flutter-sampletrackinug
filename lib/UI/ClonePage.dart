import 'package:flutter/material.dart';

import 'EditContent.dart';
import '../models/Sample.dart';

class ClonePage extends StatelessWidget {
  final Sample sample;

  const ClonePage({super.key, required this.sample});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clone an Existing Sample"),
      ),
      body: EditContent(sample: sample, status: 'clone'),
    );
  }
}
