import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../Functions/Server.dart';

// ignore: camel_case_types
class singlePrinterPage extends StatefulWidget {
  final String id;
  final String printer;

  const singlePrinterPage({super.key, required this.id, required this.printer});

  @override
  State<singlePrinterPage> createState() => _singlePrinterState();
}

// ignore: camel_case_types
class _singlePrinterState extends State<singlePrinterPage> {
  InAppWebViewController? webViewController;
  InAppWebViewSettings options = InAppWebViewSettings(
        useShouldOverrideUrlLoading: false,
        mediaPlaybackRequiresUserGesture: false,
        useHybridComposition: true,
        allowsInlineMediaPlayback: false,
      );

  @override
  void initState() {
    super.initState();
  }

  double progress = 0;

  @override
  Widget build(BuildContext context) {
    var url =
        "$SERVER_IP/sampletracking_test/sample_select.php?id=${widget.id}&room=${widget.printer}";
    print(url);

    return Scaffold(
        appBar: AppBar(
          title: const Text(" labels"),
        ),
        // ignore: avoid_unnecessary_containers
        body: Container(
          child: Column(children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              child: const Text("Printing...."),
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
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      // print('loading');
                    });
                  },
                  onLoadStop: (controller, url) async {
                    final snackBar = SnackBar(
                      content: Text('onLoadStop $url'),
                      duration: const Duration(seconds: 1),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    setState(() {});
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
          ]),
        ));
  }
}
