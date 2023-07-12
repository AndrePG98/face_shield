import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /*void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Do you want to delete this user?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    try {
                      final CollectionReference collections = FirebaseFirestore.instance.collection('users') ;
                      collections.doc(widget.id).delete();
                      Navigator.pop(context,true);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User deleted successfully!")));

                    } catch (e) {
                      print("Error deleting the user: $e");
                    }
                    if(context != null && Navigator.of(context).canPop()){
                      Navigator.pop(context,true);
                    }
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
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
          return Divider();
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
        return Icon(Icons.email);
      case 1:
        return Icon(Icons.delete);
      case 2:
        return Icon(Icons.logout);
      default:
        return Icon(Icons.error);
    }
  }

  void _handleItemClick(BuildContext context, int index) {
    switch (index) {
      case 0:
        _showEditEmailDialog(context);
        break;
      case 1:
        _showDeleteAccountConfirmationDialog(context);
        break;
      case 2:
        _logout(context);
        break;
    }
  }

  void _showEditEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String currentEmail = '';
        String newEmail = '';

        return AlertDialog(
          title: Text('Edit Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  currentEmail = value;
                },
                decoration: InputDecoration(hintText: 'Current Email'),
              ),
              SizedBox(height: 16.0),
              TextField(
                onChanged: (value) {
                  newEmail = value;
                },
                decoration: InputDecoration(hintText: 'New Email'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                // Implement the email update logic here
                // ...
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account?'),
          actions: [
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              child: Text('Delete'),
              onPressed: () {
                // Implement the account deletion logic here
                // ...
                Navigator.of(context).pop();
              },
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
