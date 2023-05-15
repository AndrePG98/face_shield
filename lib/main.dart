import 'package:face_shield/routes/SignUpPage.dart';
import 'package:face_shield/routes/camera.dart';
import 'package:face_shield/routes/forgotPassword.dart';
import 'package:face_shield/routes/home.dart';
import 'package:face_shield/routes/login.dart';
import 'package:face_shield/routes/signup/email.dart';
import 'package:face_shield/routes/signup/password.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';


main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {

  MainApp({super.key}){
    _initProcessor();
  }

  _initProcessor () async {

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Shield',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      //home: const HomePage(),
      home: const SignUpPage(),
      routes: <String, WidgetBuilder> {
        '/login' : (BuildContext context) => const LogIn(),
        '/email' : (BuildContext context) => const Email(),
        '/username' : (BuildContext context) => const Username(),
        '/recovery' : (BuildContext context) => const Recovery(),
        '/camera' : (BuildContext context) => CameraPage(),
        '/signup' : (BuildContext context) => SignUpPage()
      },
    );
  }
}