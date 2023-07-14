import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/Helpers.dart';

class UserDetailPage extends StatefulWidget {
  final String id;
  late final String email;
  final List<double> faceData;

  UserDetailPage({super.key, required this.id,required this.email, required this.faceData});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  late TextEditingController _emailController;


  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
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
  }

  void _showEditConfirmationDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Edit user"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (String? value) {
                      if (value!.trim().isEmpty) {
                        return 'The email is required!';
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
                    if (isValidEmail(_emailController.text)) {
                      setState(() {
                        _loading = true;
                      });

                      try {
                        // Update the email in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.id)
                            .update({
                          'email': _emailController.text,
                        });

                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await user.updateEmail(_emailController.text);
                        }

                        setState(() {
                          _loading = false;
                          widget.email = _emailController.text;
                        });

                        if (Navigator.of(context).canPop()) {
                          Navigator.pop(context, true);
                        }
                      } catch (error) {
                        setState(() {
                          _loading = false;
                        });
                        print("Error updating the email: $error");
                      }
                    }
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    'Edit',
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
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("User Detail"),
        ),
        body: WillPopScope(
          onWillPop: () async{
            Navigator.pop(context, true);
            return false;
          },
          child: SizedBox(
            width: double.infinity,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: !_loading
                ? Column(
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    Text(
                      _emailController.text,
                      style: const TextStyle(fontSize: 25),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 26,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showEditConfirmationDialog(context);
                            },
                            child: const Text(
                              'Edit',
                              style: TextStyle(fontSize: 25),
                            ),
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 38)),
                          ),
                        ),
                        const SizedBox(
                          width: 26,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showDeleteConfirmationDialog(context);
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(fontSize: 25),
                            ),
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 30),
                                backgroundColor: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ));
  }
}
