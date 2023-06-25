import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:face_shield/processors/FaceProcessor.dart';

Future<bool> signUp(String email, String password, {List<double>? faceDataList}) async {
  int maxRetries = 5;
  int retryDelay = 1000; // Initial delay in milliseconds

  for (int retryCount = 0; retryCount < maxRetries; retryCount++) {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'email': user.email, 'faceData': faceDataList});
        return true;
      } else {
        print("User not created!");
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('Error creating the user: ${e.code}');
      if (e.code == 'firebase_auth/too-many-requests') {
        // If the error is due to too many requests, retry after a delay
        await Future.delayed(Duration(milliseconds: retryDelay));
        // Increase the delay exponentially for the next retry
        retryDelay *= 2;
      } else {
        // If the error is not due to rate limiting, propagate the error
        return false;
      }
    }
  }

  // Maximum number of retries reached, return false
  return false;
}


Future<void> logIn(String email, String password, {List<double>? faceData}) async {
  //face comparison for login
  var user = await fetchUserByEmail(email);
  List<double> facePrediction = user!['faceData'];
  //double distance = FaceProcessor().euclideanDistance(faceData, facePrediction);
  double distance = FaceProcessor().euclideanDistance(faceData, facePrediction);

  if(distance <= 0.6){ //if ED from login attempt and prediction is small it is most likely the same person
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
  else{ // if ED from login attempt and prediction is greater than 0.05 than it is most likely not the same person
    print('Face does not match user');
    return null;
  }
}

Future<void> editEmail(String email) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print(user);
      await user.updateEmail(email);
      print("Updated Email successfuly ${user.email} ");
    } else {
      print("Error updating the Email!");
    }
}

Future<bool> checkIfUserExists(String email) async {
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final querySnapshot =  await usersCollection.where("email", isEqualTo: email).get();
  return querySnapshot.docs.isNotEmpty;
}


Future<List<Map<String, dynamic>>> fetchAllUsers() async { //lista de dicionarios de users
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final querySnapshot = await usersCollection.get();
  return querySnapshot.docs.map((doc) => doc.data()).toList();
}

Future<Map<String, dynamic>?> fetchUserByEmail(String email) async {
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final querySnapshot = await usersCollection.where('email', isEqualTo: email).limit(1).get();

  if (querySnapshot.docs.isNotEmpty) {
    final userDocument = querySnapshot.docs.first;
    return userDocument.data();
  }

  return null; // User with the specified email not found
}

Future<Map<String, dynamic>?> fetchUserByFace(List<double> face) async {
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final querySnapshot = await usersCollection.where('faceData', isEqualTo: face).limit(1).get();

  if (querySnapshot.docs.isNotEmpty) {
    final userDocument = querySnapshot.docs.first;
    return userDocument.data();
  }

  return null; // User with the specified email not found
}

