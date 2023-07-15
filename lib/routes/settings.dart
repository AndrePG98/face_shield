import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../helpers/Helpers.dart';

class SettingsPage extends StatefulWidget {
  late final String email;
  SettingsPage({required this.email});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  late TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: _getItemIcon(index),
            title: Text(_getItemTitle(index)),
            onTap: () {
              _handleItemClick(context, index);
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
        itemCount: _getItemCount(),
      ),
    );
  }

  int _getItemCount() {
    return 3; // Total number of items in the list
  }

  String _getItemTitle(int index) {
    switch (index) {
      case 0:
        return 'Edit Email';
      case 1:
        return 'Delete Account';
      case 2:
        return 'Logout';
      default:
        return '';
    }
  }

  Icon _getItemIcon(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.email);
      case 1:
        return const Icon(Icons.delete);
      case 2:
        return const Icon(Icons.logout);
      default:
        return const Icon(Icons.error);
    }
  }

  void _handleItemClick(BuildContext context, int index) {
    switch (index) {
      case 0:
        _showEditConfirmationDialog(context);
        break;
      case 1:
        _showDeleteConfirmationDialog(context);
        break;
      case 2:
        _logout(context);
        break;
    }
  }

  void _showEditConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String currentEmail = _emailController.text.trim().toLowerCase();
        late TextEditingController _newEmailController;
        _newEmailController = TextEditingController(text: currentEmail);

        return AlertDialog(
          title: const Text("Edit user"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Current Email'),
                  validator: (String? value) {
                    if (value!.trim().isEmpty) {
                      return 'The current email is required!';
                    } else if (!isValidEmail(value)) {
                      return "Invalid email";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _newEmailController,
                  decoration: const InputDecoration(labelText: 'New Email'),
                  validator: (String? value) {
                    if (value!.trim().isEmpty) {
                      return 'The new email is required!';
                    } else if (!isValidEmail(value)) {
                      return "Invalid email";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _loading = true;
                  });

                  try {
                    QuerySnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: _emailController.text)
                        .limit(1)
                        .get();
                    print("Utilizador!");
                    print(_emailController.text);
                    print(_newEmailController.text);
                    print(snapshot.docs.first);

                    if (snapshot.docs.isNotEmpty) {
                      // Atualizar o e-mail no Firestore
                      DocumentSnapshot userDoc = snapshot.docs.first;
                      await userDoc.reference.update({
                        'email': _newEmailController.text,
                      });

                      // Atualizar o e-mail na autenticação do Firebase
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await user.updateEmail(_newEmailController.text);
                      }

                      setState(() {
                        _loading = false;
                        widget.email = _newEmailController.text;
                      });

                      if (Navigator.of(context).canPop()) {
                        Navigator.pop(context, true);
                      }

                      Fluttertoast.showToast(
                        msg: "E-mail updated successfully.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "User not found with the current email.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  } catch (error) {
                    setState(() {
                      _loading = false;
                    });
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("User email edited successfully!")),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (Route<dynamic> route) => false);
                }
              },
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text(
                'Edit',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Do you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Delete the user account
                    await user.delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("User account deleted successfully!")),
                    );

                    // Navigate to the login screen or any other appropriate screen
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (Route<dynamic> route) => false,
                    );
                  }
                } catch (e) {
                  print("Error deleting the user account: $e");
                }
              },
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    // Redirect to the home page
    Navigator.pushNamedAndRemoveUntil(
        context, '/', (Route<dynamic> route) => false);
  }
}
