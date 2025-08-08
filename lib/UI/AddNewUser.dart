import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/auth/auth_repository.dart';
import '../features/samples/sample_providers.dart';
import '../providers.dart';
import 'Toast.dart';

class AddNewUser extends ConsumerStatefulWidget {
  const AddNewUser({super.key});

  @override
  _AddNewUserState createState() => _AddNewUserState();
}

class _AddNewUserState extends ConsumerState<AddNewUser> {
  final _fbKey = GlobalKey<FormBuilderState>();

  Future<void> _sendMail(String toEmail, String password) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query: 'subject=Credentials for Samples App@NCNR&body=Hi $toEmail,\n\nyour new password for the Flutter Samples App is: $password',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      toast(context, 'Could not launch email client.', Colors.red);
    }
  }

  Future<void> _submitForm() async {
    if (!_fbKey.currentState!.saveAndValidate()) {
      return;
    }

    final formData = _fbKey.currentState!.value;
    final jwt = ref.read(authStateProvider);

    if (jwt == null) {
      toast(context, "Error: Not logged in.", Colors.red);
      return;
    }

    final data = {
      "barcode": "",
      "email": formData['email'],
      "password": formData['password'] ?? "", // Password can be optional
      "name": formData['name'],
      "manager": formData['manager'] == true ? "1" : "0",
      "address": formData['address'] ?? "",
      "phone": "+1-240", // Hardcoded as per original
      "archived": "0"
    };

    try {
      final response = await ref.read(apiClientProvider).addNewUser(jwt, data: data);

      // The old API returned the password in the response body.
      final newPassword = response['password'];

      toast(context, "Added user successfully!", Colors.green);

      // Invalidate provider to refresh the user list
      ref.invalidate(allUsersProvider);

      // Ask to email the password
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('New User Password'),
          content: Text('Send password ($newPassword) to user?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
            ElevatedButton(
              onPressed: () {
                _sendMail(formData['email'], newPassword);
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      Navigator.of(context).pop(); // Pop the AddNewUser screen itself

    } catch (e) {
      toast(context, "Error adding user: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _fbKey,
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
                name: "password",
                decoration: const InputDecoration(labelText: "Password (optional)", icon: Icon(MdiIcons.key)),
              ),
              FormBuilderTextField(
                name: "address",
                decoration: const InputDecoration(labelText: "Address", icon: Icon(MdiIcons.city)),
              ),
              const SizedBox(height: 15),
              FormBuilderSwitch(
                title: const Text('Manager?'),
                name: "manager",
                initialValue: false,
                decoration: const InputDecoration(icon: Icon(MdiIcons.cardAccountDetailsStar, color: Colors.grey)),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text("Submit"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
