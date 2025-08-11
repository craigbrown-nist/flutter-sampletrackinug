import 'package:flutter/material.dart';

import 'EditContent.dart';
import '../models/Sample.dart';

class EditPage extends StatelessWidget {
  final Sample sample;

  const EditPage({super.key, required this.sample});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editing Sample ID: ${sample.sampleId ?? ''}"),
      ),
      body: EditContent(sample: sample, status: "edit"),
    );
  }
}