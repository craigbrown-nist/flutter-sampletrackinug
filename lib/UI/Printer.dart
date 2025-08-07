import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../Functions/Server.dart';

//import 'dart:io';
//const SERVER_IP = 'https://ncnr.nist.gov/flutter';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrinterState createState() => _PrinterState();
}

class _PrinterState extends State<PrinterPage> {
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: false,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: false,
      ));

  var url = "$SERVER_IP/sampletracking_test/samples_highbay.php";
  double progress = 0;
  List<bool> isSelected = [true, false, false, false];

  FocusNode focusNodeButton1 = FocusNode();
  FocusNode focusNodeButton2 = FocusNode();
  FocusNode focusNodeButton3 = FocusNode();
  FocusNode focusNodeButton4 = FocusNode();
  // FocusNode focusNodeButton3 = FocusNode();
  late List<FocusNode> focusToggle;
  List urlList = [
    "$SERVER_IP/sampletracking_test/samples_highbay.php",
    "$SERVER_IP/sampletracking_test/samples_g100.php",
    "$SERVER_IP/sampletracking_test/samples_e131.php",
    "$SERVER_IP/sampletracking_test/samples_b147.php"
  ];

  @override
  void initState() {
    super.initState();
    focusToggle = [
      focusNodeButton1,
      focusNodeButton2,
      focusNodeButton3,
      focusNodeButton4
    ];
    urlList = [
      '$SERVER_IP/sampletracking_test/samples_highbay.php',
      '$SERVER_IP/sampletracking_test/samples_g100.php',
      '$SERVER_IP/sampletracking_test/samples_e131.php',
      '$SERVER_IP/sampletracking_test/samples_b147.php'
    ];
  }

  // void _click(url) async {
  //   print(url);

  //   if (Platform.isAndroid) {
  //     await webViewController?.loadUrl(urlRequest: url);
  //   } else if (Platform.isIOS) {
  //     webViewController?.loadUrl(urlRequest: URLRequest(url: url));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(" labels"),
        ),
        // ignore: avoid_unnecessary_containers
        body: Container(
          child: Column(children: <Widget>[
            ToggleButtons(
              color: Colors.blueAccent,
              selectedColor: Colors.amberAccent,
              fillColor: const Color.fromRGBO(158, 166, 186, 1.0),
              splashColor: Colors.lightBlue,
              highlightColor: Colors.lightBlue,
              borderColor: Colors.grey[400],
              borderWidth: 2,
              selectedBorderColor: Colors.blueAccent,
              renderBorder: true,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)),
              disabledColor: Colors.blueGrey,
              disabledBorderColor: Colors.blueGrey,
              focusColor: Colors.red,
              focusNodes: focusToggle,
              isSelected: isSelected,
              onPressed: (int index) {
                setState(() {
                  for (int indexBtn = 0;
                      indexBtn < isSelected.length;
                      indexBtn++) {
                    if (indexBtn == index) {
                      isSelected[indexBtn] = true;
                      url = urlList[index];
                    } else {
                      isSelected[indexBtn] = false;
                    }
                  }
                });
                final ttt = urlList[index].toString();
                print('list: $ttt');
                webViewController?.loadUrl(
                    urlRequest: URLRequest(url: Uri.parse(ttt)));
                // print(urlList[index]);
                //_click(urlList[index]);
              },
              children: const <Widget>[
                Text(" HighBay "),
                Text("Guidehall"),
                Text("   E-131   "),
                Text("   B-147   "),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: const Text("Choose a printer Location"),
              //child: Text("${((url.split('/')[(url.split('/').length - 1)]))}"),
            ),
            Container(
                padding: const EdgeInsets.all(3.0),
                child: progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container()),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                    //useShouldOverrideUrlLoading: true,
                    //debuggingEnabled: true,
                    javaScriptEnabled: true,
                  )),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      print(url);
                      this.url = url?.toString() ?? '';
                      // print('loading');
                    });
                  },
                  onLoadStop: (controller, url) async {
                    final snackBar = SnackBar(
                      content: Text('onLoadStop $url'),
                      duration: const Duration(seconds: 1),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    setState(() {
                      this.url = url?.toString() ?? '';
                    });
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OverflowBar(
                alignment: MainAxisAlignment.center,
                spacing: 8.0,
                overflowSpacing: 8.0,
                children: <Widget>[
                  ElevatedButton(
                    child: const Icon(Icons.refresh),
                    onPressed: () {
                      webViewController?.reload();
                      if (webViewController?.runtimeType == Object) {
                        // print('Object');
                      } else {
                        // print('not object');
                      }
                    },
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}
