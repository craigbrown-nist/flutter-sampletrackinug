import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'main.dart';
import 'API.dart';
import 'dart:async';

//import 'ListPage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoggedIn = false;
  bool _obscureText = true;
  String datauser = '';
  String msg = '';
  String jwt = '';

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    autoLogIn();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  saveBoolValue(String key, bool value) async {
    // get shared preference instance.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Set the key ('isLoggenIn') with a value (true/false) here.
    prefs.setBool(key, value);
  }

  saveStrValue(String key, String value) async {
    // get shared preference instance.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Set the key ('isLoggenIn') with a value (true/false) here.
    prefs.setString(key, value);
    //print(key.toString() + " " + value.toString());
  }

  void autoLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? datauser = prefs.getString('datauser');
    final bool? isLoggedIn = prefs.getBool('isLoggedIn');
    final String? jwt = prefs.getString('jwt');

    if (isLoggedIn != null && isLoggedIn == true) {
      // ignore: use_build_context_synchronously
      final container = MyInheritedWidget.of(context, false);

      // check the jwt is valid first!
      if (jwt != null && jwt != "") {
        //  check expiry of jwt
        var str = jwt.split(".");
        if (str.length != 3) {
          setState(() {
            // print(jwt);
            msg = "Login Error (jwt token fail) for autologin";
            prefs.setString('jwt', '');
            prefs.setBool('isLoggedIn', false);
          });
        } else {
          var payload = json
              .decode(ascii.decode(base64.decode(base64.normalize(str[1]))));
          if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
              .isAfter(DateTime.now())) {
            // print('jwt expires: ' +
            //     (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
            //         .toString()));

            container.setJwt(jwt);
            container.setEmail(datauser!);
            // check user is admin or not:


            //print(datauser + ' is auto-logged in');
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(context, '/myhome');
            // Authenticated! Navigate to home screen.
          } else {}
        }
      }
    }
  }

  _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: use_build_context_synchronously
    final container = MyInheritedWidget.of(context, false);

    //print(prefs.getString('jwt'));
    prefs.setString('datauser', "");
    prefs.setBool('isLoggedIn', false);
    prefs.setString('jwt', "");
    print('resetting preferences');
    print(prefs.getString('jwt'));

    container.setJwt('');
    container.setEmail("");
    container.setAdmin(false);
    container.setIndex(-1);
    container.deleteSamplesToEdit;
    container.setUser("");
    container.clearEmails();
    container.clearUsers();


    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/');
  }

  _login() async {
    final prefs = await SharedPreferences.getInstance();
      // This is where we get the JWT.
      if (user.text.length < 4) {
        setState(() {
          msg =
              "Invalid Username.\n The username should be at least 4 characters long";
        });
      } else if (pass.text.length < 4) {
        setState(() {
          msg =
              "Invalid Password.\n The password should be at least 4 characters long";
        });
      } else {
        API.attemptLogIn(user.text, pass.text).then((jwt) {
          // ignore: use_build_context_synchronously
          final container = MyInheritedWidget.of(context, false);
          // print(jwt);`
          // ignore: unnecessary_null_comparison
          if (jwt != null) {
            datauser = user.text;
            var str = jwt.split(".");
            if (str.length != 3) {
              setState(() {
                // print(jwt);
                print("Can't get the JWT");
                msg = "Login Error (jwt token fail)";
                logout();
              });
            } else {
              var payload = json.decode(
                  ascii.decode(base64.decode(base64.normalize(str[1]))));
              if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                  .isAfter(DateTime.now())) {
                // print('jwt expires' +
                //     (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                //         .toString()));
                setState(() {
                  msg = "Login Accepted";
                });

                // save all preferences
                prefs.setString('datauser', datauser);
                prefs.setBool('isLoggedIn', true);
                prefs.setString('jwt', jwt);

                print("Logging in as : " + datauser);
                print("");

                //saveBoolValue('isLoggedIn', true);
                //saveStrValue('datauser', datauser);
                //saveStrValue('jwt', jwt);

                //and to inherited widget
                container.setEmail(datauser);
                container.setJwt(jwt);

                // go to home listing
// ignore: unused_local_variable
final timer = Timer(
  const Duration(seconds: 3),
  () {
     print("Pushing -> home");
                print("");
    Navigator.pushReplacementNamed(context, '/myhome');
  },
);
                

              } else {
                setState(() {
                  msg = "Login Error";
                  logout();
                });
              }
            }
          } else {
            setState(() {
              msg = "Login Error";
              logout();
            });
          }
        });
      }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Form(
            child: Container(
          decoration:  const BoxDecoration(
              image:  DecorationImage(
                  image:  AssetImage('assets/images/blue_glow.jpg'),
                  fit: BoxFit.cover)),
          child: Column(
            children: <Widget>[
              // new Container(
              //   padding: EdgeInsets.only(top: 77.0),
              //   child: new CircleAvatar(
              //     backgroundColor: Colors.grey,
              //     child: new Image(
              //       width: 400,
              //       height: 400,
              //       image: new AssetImage('assets/images/avatar.jpg'),
              //     ),
              //   ),
              //   width: 330,
              //   height: 330,
              //   decoration: BoxDecoration(shape: BoxShape.circle),
              // ),
              Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: const Text('Sample Tracking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40))),
              Container(
                height: MediaQuery.of(context).size.height / 1.8,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(top: 53),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      padding: const EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(158, 166, 186, 1.0),
                                blurRadius: 5)
                          ]),
                      child: TextFormField(
                        controller: user,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.email,
                            color: Color.fromRGBO(158, 166, 186, 1.0),
                          ),
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: 50,
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(158, 166, 186, 1.0),
                                blurRadius: 5)
                          ]),
                      child: TextFormField(
                        controller: pass,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          icon: const Icon(
                            Icons.vpn_key,
                            color: Color.fromRGBO(158, 166, 186, 1.0),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: _togglePassword,
                            child: const Icon(Icons.remove_red_eye),
                          ),
                          hintText: 'Password',
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 6, right: 32, left: 32, bottom: 2),
                        child: Text(
                          'App version' +
                              _packageInfo.version.toString() +
                              " + " +
                              _packageInfo.buildNumber,
                          //'Reset Password',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                      onPressed: () {
                        _login();
                      },
                      child: const Text('Submit'),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: Text(
                    //     'Or',
                    //     style: TextStyle(color: Colors.white),
                    //   ),
                    // ),
                    // new ElevatedButton(
                    //   child: const Text('Login with Orcid'),
                    //   style: ElevatedButton.styleFrom(
                    //     primary: Colors.orangeAccent,
                    //     onPrimary: Colors.black,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: new BorderRadius.circular(30.0),
                    //       side: BorderSide(color: Colors.red),
                    //     ),
                    //   ),
                    //   onPressed: _launchURL,
                    // ),
                    const Spacer(),
                    Text(
                      msg,
                      style: const TextStyle(
                          fontSize: 15.0,
                          color: Color.fromARGB(255, 231, 244, 54)),
                    )
                  ],
                ),
              ),
            ],
          ),
        )));
  }
}

// const _url =
//     'https://sandbox.orcid.org/oauth/authorize?client_id=APP-IPP05E0V26N7MYK0&response_type=code&scope=/authenticate&redirect_uri=https://samples.ncnr.nist.gov/orcid';
// void _launchURL() async => await canLaunchUrl(Uri.parse(_url))
//     ? await launchUrl(Uri.parse(_url))
//     : throw 'could not launch $_url';
