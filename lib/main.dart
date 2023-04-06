import 'package:face_shield/components/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'components/pages/home.dart';

main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Shield',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blue
      ),
      home: const HomePage(),
      routes: <String, WidgetBuilder> {
        '/signin' : (BuildContext context) => const SignIn(),
      },
    );
  }
}
