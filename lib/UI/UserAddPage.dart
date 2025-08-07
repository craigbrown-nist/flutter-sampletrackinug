import 'package:flutter/material.dart';
import 'AddNewUser.dart';

class UserAddPage extends StatefulWidget {
  const UserAddPage({super.key});

  @override
  UserAddPageState createState() => UserAddPageState();
}

class UserAddPageState extends State<UserAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adding a New User"),
      ),
      body: const AddNewUser(),
    );
  }
}
