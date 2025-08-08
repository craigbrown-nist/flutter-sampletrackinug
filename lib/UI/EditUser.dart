import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/auth/auth_repository.dart';
import '../features/samples/sample_providers.dart';
import '../models/User.dart';
import '../providers.dart';
import 'Toast.dart';

class EditUser extends ConsumerStatefulWidget {
  final User user;
  const EditUser({super.key, required this.user});

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends ConsumerState<EditUser> {
  final _fbKey = GlobalKey<FormBuilderState>();

  Future<void> _sendMail(String toEmail, String password) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query: 'subject=Credentials for Samples App@NCNR&body=Hi $toEmail,\n\nyour new password is: $password',
    );
    if (!await launchUrl(emailLaunchUri)) {
      toast(context, 'Could not launch email client.', Colors.red);
    }
  }

  Future<void> _submitUpdate() async {
    if (!_fbKey.currentState!.saveAndValidate()) return;

    final formData = _fbKey.currentState!.value;
    final jwt = ref.read(authStateProvider);
    if (jwt == null) return;

    final data = {
      "barcode": "User_${widget.user.id}",
      "email": formData['email'],
      "name": formData['name'],
      "manager": formData['manager'] == true ? "1" : "0",
      "address": formData['address'] ?? "",
      "phone": "+1-240", // Hardcoded as per original
      "archived": formData['archived'] == true ? "1" : "0",
    };

    try {
      await ref.read(apiClientProvider).updateUser(jwt, id: widget.user.id!, data: data);
      ref.invalidate(allUsersProvider);
      toast(context, "User updated successfully!", Colors.green);
      Navigator.of(context).pop();
    } catch (e) {
      toast(context, "Error updating user: $e", Colors.red);
    }
  }

  Future<void> _resetPassword() async {
    final jwt = ref.read(authStateProvider);
    if (jwt == null) return;

    final userEmail = widget.user.email;
    if (userEmail == null) return;

    try {
      final response = await ref.read(apiClientProvider).updateUserPassword(jwt, userEmail);
      final newPassword = response['password'];

      toast(context, "Password reset successfully!", Colors.green);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New Password'),
          content: Text('Send password ($newPassword) to user?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
            ElevatedButton(
              onPressed: () {
                _sendMail(userEmail, newPassword);
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    } catch (e) {
      toast(context, "Error resetting password: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit User: ${widget.user.name ?? ''}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _fbKey,
          initialValue: {
            'name': widget.user.name,
            'email': widget.user.email,
            'address': widget.user.address,
            'manager': widget.user.manager == '1',
            'archived': widget.user.archived == '1',
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FormBuilderTextField(
                name: "name",
                decoration: const InputDecoration(labelText: "Name", icon: Icon(MdiIcons.pirate)),
                validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
              ),
              FormBuilderTextField(
                name: "email",
                decoration: const InputDecoration(labelText: "Email", icon: Icon(MdiIcons.email)),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              FormBuilderTextField(
                name: "address",
                decoration: const InputDecoration(labelText: "Address", icon: Icon(MdiIcons.city)),
              ),
              const SizedBox(height: 15),
              FormBuilderSwitch(
                title: const Text('Manager?'),
                name: "manager",
                decoration: const InputDecoration(icon: Icon(MdiIcons.cardAccountDetailsStar, color: Colors.grey)),
              ),
              const SizedBox(height: 15),
              FormBuilderSwitch(
                title: const Text('Archive this user?'),
                name: "archived",
                decoration: const InputDecoration(icon: Icon(MdiIcons.trashCan, color: Colors.grey)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitUpdate,
                child: const Text("Submit Changes"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Get a new password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
