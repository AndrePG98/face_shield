import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_shield/routes/UserDetailPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListUsersPage extends StatefulWidget {
  const ListUsersPage({Key? key}) : super(key: key);

  @override
  State<ListUsersPage> createState() => _ListUsersPage();
}

class _ListUsersPage extends State<ListUsersPage> {
  List<UserData> userList = [];
  bool _loading = false;

  void _loadUserData() async {
    try {
      setState(() {
        _loading=true;
      });
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        userList = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return UserData(
            id: doc.id,
            email: data['email'] ?? '',
            faceData: List<double>.from(data['faceData'] ?? []),
          );
        }).toList();
        _loading=false;
      });
    } catch (e) {
      print("Error loading user's data! $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> deleteAllDocuments() async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await usersCollection.get();
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
    _loadUserData();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List Users"),
      ),
      body: userList.isNotEmpty
          ? Column(
        children: [
          OutlinedButton(
            onPressed: deleteAllDocuments,
            child: const Text("Delete All"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final userData = userList[index];
                return Card(
                  child: ListTile(
                    title: Text('Email: ${userData.email}'),
                    subtitle: Text('Face Data: ${userData.faceData.length}'),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailPage(
                            id: userData.id,
                            email: userData.email,
                            faceData: userData.faceData,
                          ),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _loadUserData();
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      )
          : userList.isEmpty && !_loading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No registered users!",
              style: TextStyle(fontSize: 28),
            ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class UserData {
  final String id;
  final String email;
  final List<double> faceData;

  UserData({required this.id, required this.email, required this.faceData});
}
