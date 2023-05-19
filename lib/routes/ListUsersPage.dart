import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListUsersPage extends StatefulWidget {
  const ListUsersPage({Key? key}) : super(key: key);

  @override
  State<ListUsersPage> createState() => _ListUsersPage();
}

class _ListUsersPage extends State<ListUsersPage> {
  List<UserData> userList = [];

  void _loadUserData() async {
    try {
      QuerySnapshot snapshot=await FirebaseFirestore.instance.collection('users').get();

      if (snapshot.docs.isNotEmpty != null) {
        print("Lista de utilizadores");
        print(snapshot.docs[0]);
        setState(() {
        //userList = snapshot.docs.map((e) => UserData(email: e.data()['email'], faceData: List<double>.from(e.data()['faceData']))).toList();
          userList = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return UserData(
              email: data['email'] ?? '',
              faceData: List<double>.from(data['faceData'] ?? []),
            );
          }).toList();
       });
        print(userList);


      }
    } catch (e) {
      print("Erro ao carregar dados do utilizador $e");
    }
  }

  @override
  void initState(){
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("List Users"),
        ),
        body: userList.length > 0 ? Text('teste ${userList.length}')
        /*ListView.builder(itemBuilder: (context, index) {
          final userData=userList[index];
          return Card(
            child: ListTile(
              title: Text('Email: ${userData.email}'),
              subtitle: Text('Face Data: ${userData.faceData}'),
            ),
          );*/
         : CircularProgressIndicator());
  }
}

class UserData {
  final String email;
  final List<double> faceData;

  UserData({required this.email,required this.faceData});
}
