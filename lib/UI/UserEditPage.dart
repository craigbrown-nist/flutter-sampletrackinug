import 'package:flutter/material.dart';
import 'EditUser.dart';
import '../models/User.dart';

class UserEditPage extends StatefulWidget {
  final User user;

  const UserEditPage({super.key, required this.user});

  /// if this.user is passed then assum it is edited.
  /// if nothing is passed then it is a new user.
  ///

  @override
  UserEditPageState createState() => UserEditPageState();
}

class UserEditPageState extends State<UserEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editing User: ${int.parse(widget.user.id!)}"),
      ),
      body: EditUser(user: widget.user),
      //body: EditContent(sample: new  Sample(), status: "new"),
    );
  }
}
