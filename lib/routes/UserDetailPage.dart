import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserDetailPage extends StatelessWidget {
  final String email;
  final List<double> faceData;

  UserDetailPage({required this.email, required this.faceData});

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
                      /*QuerySnapshot snapshot =
                      await FirebaseFirestore.instance.collection('users').get();*/
                      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(email);
                      DocumentSnapshot documentSnapshot = await userRef.get();
                      print('userRed');
                      print(documentSnapshot.reference);
                      /*if(doc.exists) {
                        await userRef.delete();
                        print('User eliminado com sucesso');
                      } else {
                        print('User não existe');
                      }
*/
                    } catch (e) {
                      print("Erro ao eliminar utilizador: $e");
                    }
                    if(context != null && Navigator.of(context).canPop()){
                      Navigator.of(context).pop();
                    }
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("User Detail"),
        ),
        body: Container(
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  Text(
                    email,
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'FaceData',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  Text(
                    faceData.toString(),
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(
                    height: 26,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            'Edit',
                            style: TextStyle(fontSize: 25),
                          ),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 38)),
                        ),
                      ),
                      SizedBox(
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 30),
                              backgroundColor: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
