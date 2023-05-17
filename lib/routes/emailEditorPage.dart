import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/api.dart';

class EmailEditorPage extends StatefulWidget {
  const EmailEditorPage({Key? key}) : super(key: key);

  @override
  State<EmailEditorPage> createState() => _EmailEditorPageState();
}

class _EmailEditorPageState extends State<EmailEditorPage>{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  void _updateEmail() async {
    try{
      User? user = _auth.currentUser;
      if(user != null){
        await user.updateEmail(_emailController.text);
        print("Email atualizado com sucesso ${user.email}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email atualizado")));
  }

  }
  catch(e){
      print("Erro ao atualizar email! $e");
  }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit email"),
        ),
        body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    onPressed: () {
                    //editEmail(_emailController.text);
                      _updateEmail();
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text("Edit Email"))
              ],
            )));
  }
}

