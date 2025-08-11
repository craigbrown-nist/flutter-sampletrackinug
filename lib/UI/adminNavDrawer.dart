import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../features/auth/auth_repository.dart';
import '../Functions/Server.dart';

 
 
// The new, modern implementation of the navigation drawer.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final bool isAdmin = currentUser.value?.manager == '1';
    final String userName = currentUser.value?.name ?? 'Loading...';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildDrawerHeader(userName),

          ListTile(
            leading: const Icon(Icons.local_library),
            title: const Text('My samples'),
            onTap: () => _navigateTo(context, '/myhome'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_input_composite),
            title: const Text('Cells'),
            onTap: () => _navigateTo(context, '/cells'),
          ),

          // Platform-specific and Admin-specific items
          ..._buildPlatformAndAdminItems(context, isAdmin),

          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('About'),
            onTap: () => _navigateTo(context, '/about'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              await ref.read(authRepositoryProvider).logout();
              // Navigate to login screen after logout
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeName) {
    // Close the drawer first
    Navigator.of(context).pop();
    // Then navigate. A short delay ensures the drawer is closed before the new page appears.
    Future.delayed(const Duration(milliseconds: 100), () {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamed(routeName);
    });
  }

  DrawerHeader _buildDrawerHeader(String userName) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(158, 166, 186, 1.0),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage('assets/images/ncnr.jpg'),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Menu",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 40,
              shadows: [
                Shadow(offset: Offset(-1.5, -1.5), color: Colors.black54),
                Shadow(offset: Offset(1.5, -1.5), color: Colors.black54),
                Shadow(offset: Offset(1.5, 1.5), color: Colors.black54),
                Shadow(offset: Offset(-1.5, 1.5), color: Colors.black54),
              ],
            ),
          ),
          const Spacer(),
          Text(
            userName,
            textAlign: TextAlign.left,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlatformAndAdminItems(BuildContext context, bool isAdmin) {
    final bool isDesktop = kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    List<Widget> items = [];

    // Scan button
    items.add(ListTile(
      leading:  Icon(MdiIcons.qrcode),
      title: const Text('Scan'),
      onTap: () => _navigateTo(context, isDesktop ? '/scanWin' : '/scan'),
    ));

    // Printers / Web Print
    if (isDesktop) {
       items.add(ListTile(
        leading: const Icon(Icons.print),
        title: const Text('Web Print'),
        onTap: () async {
          final Uri url = Uri.parse('$SERVER_IP/sampletracking_test/samples_b147.php');
          if (!await launchUrl(url)) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $url')));
          }
        },
      ));
    } else {
      items.add(ListTile(
        leading: const Icon(Icons.print),
        title: const Text('Printers'),
        onTap: () => _navigateTo(context, '/printers'),
      ));
    }

    // Admin-only items
    if (isAdmin) {
      items.add(const Divider());
      items.add(ListTile(
        leading: const Icon(Icons.face),
        title: const Text('Users'),
        onTap: () => _navigateTo(context, '/users'),
      ));
      items.add(ListTile(
        leading: const Icon(Icons.palette),
        title: const Text('All Samples'),
        onTap: () => _navigateTo(context, '/all'),
      ));
       items.add(ListTile(
        leading: const Icon(Icons.autorenew),
        title: const Text('To Empty'),
        onTap: () => _navigateTo(context, '/empty'),
      ));
    }

    return items;
  }
}
