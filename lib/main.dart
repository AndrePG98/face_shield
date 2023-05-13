import 'package:face_shield/routes/camera.dart';
import 'package:face_shield/routes/forgotPassword.dart';
import 'package:face_shield/routes/home.dart';
import 'package:face_shield/routes/login.dart';
import 'package:face_shield/routes/signup/email.dart';
import 'package:face_shield/routes/signup/password.dart';
import 'package:flutter/material.dart';


main() async {
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
      home: const HomePage(),
      routes: <String, WidgetBuilder> {
        '/login' : (BuildContext context) => const LogIn(),
        '/email' : (BuildContext context) => const Email(),
        '/username' : (BuildContext context) => const Username(),
        '/recovery' : (BuildContext context) => const Recovery(),
        '/camera' : (BuildContext context) => CameraPage(),
      },
    );
  }
}