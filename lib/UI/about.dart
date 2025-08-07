import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 120.0,
          pinned: true,
          leading: IconButton.filledTonal(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          //title:  Text( '_SliverAppBar')  ,
          flexibleSpace: FlexibleSpaceBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const Text(
                  'Flutter Samples',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                const Text(
                  'Craig Brown, NIST',
                  style: TextStyle(color: Colors.white, fontSize: 10.0),
                ),
                Text(
                  'App version ' +
                      _packageInfo.version.toString() +
                      " + " +
                      _packageInfo.buildNumber,
                  style: const TextStyle(color: Colors.white, fontSize: 10.0),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const ListTile(
              leading: ExcludeSemantics(
                child: Icon(Icons.local_library),
              ),
              title: Text(
                'About',
              ),
              subtitle: Text(
                  "This app was written to allow users and staff to record samples that are at the NCNR for experimental purposes. So far, it is limited in scope for select fields and possible instrument locations. We will accept suggestions for improvement and if you find bugs!"),
            ),
            const ListTile(
              leading: ExcludeSemantics(
                child: Icon(Icons.local_library),
              ),
              title: Text(
                'Policy',
              ),
              subtitle: SelectableText(
                  "https://www.nist.gov/disclaimer \nThis app is intended only for use in the NCNR. The information you supply is available within the NCNR, and can be used to locate samples/cells/equipment. \nAny contact information you provide is solely to expedite login procedures and allocate samples to you. \nIf you supply a telephone number and address we assume that these are for shipping purposes (should we get to building that part of the app.) \nNo information that is supplied will be used for advertising or sold."),
            ),
            const ListTile(
              leading: ExcludeSemantics(
                child: Icon(Icons.local_library),
              ),
              title: Text(
                'Server and database:',
              ),
              subtitle:
                  SelectableText("Alan Munter\n x6244 \nalan.munter@nist.gov "),
            ),
            const ListTile(
              leading: ExcludeSemantics(
                child: Icon(Icons.local_library),
              ),
              title: Text(
                'Author:',
              ),
              subtitle: SelectableText(
                  "2020, Craig Brown \n x5134 \ncraig.brown@nist.gov \nwaitingfor.cmb@gmail.com "),
            ),
          ]),
        ),
      ]),
    );
  }
}
