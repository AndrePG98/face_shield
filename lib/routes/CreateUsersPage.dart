import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CreateUsersPage extends StatefulWidget {
  const CreateUsersPage({Key? key}) : super(key: key);

  @override
  State<CreateUsersPage> createState() => _CreateUsersPageState();
}

class _CreateUsersPageState extends State<CreateUsersPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _facedataControllerx = TextEditingController();
  final TextEditingController _facedataControllery = TextEditingController();
  final TextEditingController _facedataControllerz = TextEditingController();

  List<FaceData> faceDataList = [];

  void _addFaceData() async {
    double x = double.parse(_facedataControllerx.text);
    double y = double.parse(_facedataControllery.text);
    double z = double.parse(_facedataControllerz.text);
    FaceData faceData = FaceData(x: x, y: y, z: z);
    setState(() {
      faceDataList.add(faceData);
    });
    _facedataControllerx.clear();
    _facedataControllery.clear();
    _facedataControllerz.clear();
  }

  void _createUsers() async {
    String name = _usernameController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: name, password: password);
      String uid = userCredential.user!.uid;
      final databaseReference = FirebaseDatabase.instance.ref();

      await databaseReference.child('users').child(uid).set({
        'name': name,
        'password': password,
        'faceDataList': faceDataList
            .map((faceData) =>
                {'x': faceData.x, 'y': faceData.y, 'z': faceData.z})
            .toList()
      });
      _usernameController.clear();
      _passwordController.clear();
      setState(() {
        faceDataList.clear();
      });
      print("Utilizador criado com sucesso");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Utilizador criado com sucesso")));
    } catch (e) {
      print("Erro ao criar utilizador $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Falha ao criar utilizador")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Create Users"),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                TextField(
                  controller: _facedataControllerx,
                  decoration: InputDecoration(labelText: "x"),
                ),
                TextField(
                  controller: _facedataControllery,
                  decoration: InputDecoration(labelText: "y"),
                ),
                TextField(
                  controller: _facedataControllerz,
                  decoration: InputDecoration(labelText: "z"),
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                    onPressed: _addFaceData, child: Text("Add FaceData")),
                SizedBox(
                  height: 16,
                ),
                Text("Face Data List"),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: faceDataList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        'X: ${faceDataList[index].x.toStringAsFixed(2)}, Y: ${faceDataList[index].y.toStringAsFixed(2)}, Z: ${faceDataList[index].z.toStringAsFixed(2)}',
                      ),
                    );
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      //editEmail(_emailController.text);
                      _createUsers();

                    },
                    child: Text("Submit")),
                SizedBox(
                  height: 16,
                ),
              ])),
        ));
  }
}

class FaceData {
  final double x;
  final double y;
  final double z;
  FaceData({required this.x, required this.y, required this.z});
}
