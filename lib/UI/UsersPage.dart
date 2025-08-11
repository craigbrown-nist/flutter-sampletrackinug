import 'dart:convert';
import 'dart:async';
// ignore: import_of_legacy_library_into_null_safe
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'Toast.dart';
import '../API.dart';
import '../main.dart';
import '../models/User.dart';
import 'UserEditPage.dart';
import 'UserAddPage.dart';
import 'adminNavDrawer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool somthingWrong = true;
  var users = List<User>.empty(growable: true);

  TextEditingController allcontroller = TextEditingController();

  @override
  initState() {
    _getUsers();

    setState(() {});
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Future _refreshUsers() async {
    // print('trying to refresh');
    _getUsers();
  }

  _getUsers() {
    final container = MyInheritedWidget.of(context, false);
//    API.getUserSamples(user).then((response) {
    API.getUsers(container.getjwt).then((response) {
      setState(() {
        if (response.statusCode == 200) {
          // print('Network response is good: ' + response.statusCode.toString());
          Iterable list = json.decode(response.body);
          users = list.map((model) => User.fromJson(model)).toList();
          // for (User p in users) {
          //   print(p.name + " " + p.email);
          // }
          users.removeRange(0,
              1); // Note we do this as there seems to be a '00000' in the database
          // now trim the data to only those of the specified user from above

          // for (var i = 0; i < users.length; i++) {
          //   print(users[i].fullname + ' ' + users[i].manager);
          // }

          toast(context, "Updating users", Colors.green);

          somthingWrong = false;
          if (users.isEmpty) {
            somthingWrong = true;
            throw Exception('Failed to get any data for users; are there any?');
          }
        } else {
          somthingWrong = true;
          toast(context, "Network issues?", Colors.red);
          throw Exception('Failed to load data: Network issues?');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    final makeBody = Container(
      child: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return Ink(
              decoration: BoxDecoration(
                border: index == 0
                    ? const Border() // This will create no border for the first item
                    : Border(
                        top: BorderSide(
                            width: 1,
                            color: Theme.of(context)
                                .primaryColor)), // This will create top borders for the rest
                color: Colors.transparent,
              ),
              child: ListTile(
                  title: Text(users[index].name.toString(),
                      style: (users[index].archived == "1")
                          ? TextStyle(color: Colors.grey[400])
                          : const TextStyle(color: Colors.black)),
                  subtitle: Text(users[index].email.toString(),
                      style: (users[index].archived == "1")
                          ? TextStyle(color: Colors.grey[400])
                          : const TextStyle(color: Colors.black)),
                  leading: (users[index].manager == "1")
                      ? Icon(Icons.fingerprint, color: Colors.blue[200])
                      : const Icon(Icons.person_outline),
                  onTap: () {
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UserEditPage(user: users[index])));
                    });
                  }),
            );
          },
          // separatorBuilder: (context, index) {
          //   return Divider(
          //     color: Colors.black,
          //   );
          // },
        ),
      ),
    );

    final makeBottom = SizedBox(
      height: 55.0,
      child: BottomAppBar(
        color: const Color.fromRGBO(158, 166, 186, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.fingerprint, color: Colors.white),
              onPressed: () {
                setState(() {
                  users.sort((b, a) => (a.manager!).compareTo(b.manager!));
                });
              },
            ),
            IconButton(
              icon: const Icon(MdiIcons.orderAlphabeticalDescending,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  users.sort((a, b) =>
                      (a.name!.toLowerCase()).compareTo(b.name!.toLowerCase()));
                });
              },
            ),
            IconButton(
              icon: const Icon(MdiIcons.recycle, color: Colors.white),
              onPressed: () {
                setState(() {
                  _refreshUsers();
                });
              },
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      drawer: adminNavDrawer(context),
      appBar: AppBar(
        // iconTheme:
        //      IconThemeData(color: Color.fromRGBO(158, 166, 186, 1.0)
        // ),
        title: const Text("Users"),
        centerTitle: true,
      ),
      body: makeBody,
      bottomNavigationBar: makeBottom,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const UserAddPage(),
            )),
      ),
    );
  }
}
