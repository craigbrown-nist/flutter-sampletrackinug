import 'package:flutter/material.dart';
import 'MoveContent.dart';
import '../models/Sample.dart';

class MovePage extends StatefulWidget {
  final Sample sample;

  const MovePage({super.key, required this.sample});

  @override
  MovePageState createState() => MovePageState();
}

class MovePageState extends State<MovePage> {
  String status = "move";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Moving Sample ID: ${int.parse(widget.sample.sampleId.toString())}"),
      ),
      body: MoveContent(sample: widget.sample, status: status),
      //body: EditContent(sample: new  Sample(), status: "new"),
    );
  }
}
