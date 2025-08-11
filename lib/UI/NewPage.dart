import 'package:flutter/material.dart';

import 'EditContent.dart';
import '../models/Sample.dart';

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a New Sample"),
      ),
      // Always show the single, unified EditContent widget
      body: EditContent(sample: Sample(), status: "new"),
    );
  }
}