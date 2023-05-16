import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> signUp(String email, String password) async {
  try {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final UserCredential userCredential =
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = userCredential.user;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'email': user.email});
      print("Utilizador criado ${userCredential.user!.uid} ");
    }
    else{
      print("User não criado!");
    }
  } catch (e) {
    print('Erro ao criar utilizador: $e');
  }
}


Future<void> logIn(String email, String password) async {
  try {
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    final User? user = userCredential.user;

    if (user != null) {
      print("Utilizador logado ${userCredential.user!.uid} ");
    }

  } catch (e) {
    print('Erro ao autenticar utilizador: $e');
  }
}