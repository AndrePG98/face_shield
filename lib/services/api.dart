import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> signUp(String email, String password) async {
  try {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final UserCredential userCredential =
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    Random random = Random();
    double randomNumber = random.nextDouble();
    List<double> faceDataList = [randomNumber];
    final User? user = userCredential.user;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'email': user.email,'faceData': faceDataList});
      return true;
    }
    else{
      print("User not created!");
      return false;
    }
  } catch (e) {
    print('Error creating the user: $e');
    return false;
  }
}


Future<void> logIn(String email, String password) async {
  try {
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    final User? user = userCredential.user;

    if (user != null) {
      print("User logged in ${userCredential.user!.uid} ");
    }

  } catch (e) {
    print('Error authenticating the user: $e');
  }
}

Future<void> editEmail(String email) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print(user);
      await user?.updateEmail(email);
      print("Updated Email successfuly ${user.email} ");
    } else {
      print("Error updating the Email!");
    }
  }
