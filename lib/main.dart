import 'package:face_shield/routes/FeedPage.dart';
import 'package:face_shield/routes/ListUsersPage.dart';
import 'package:face_shield/routes/SignUpDetectionRoute.dart';
import 'package:face_shield/routes/SignUpPage.dart';
import 'package:face_shield/routes/UserDetailPage.dart';
import 'package:face_shield/routes/FeedPage.dart';
import 'package:face_shield/routes/LogInDetectionRoute.dart';
import 'package:face_shield/routes/forgotPassword.dart';
import 'package:face_shield/routes/home.dart';
import 'package:face_shield/routes/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const HomePage(),
      routes: <String, WidgetBuilder> {
        '/login' : (BuildContext context) => LogInDetectionWidget(),
        '/faceRegister' : (BuildContext context) => SignUpDetectionWidget(),
        '/recovery' : (BuildContext context) => const Recovery(),
        '/signup' : (BuildContext context) => const SignUpPage(),
        '/listusers': (BuildContext context) => const ListUsersPage(),
        '/feed' : (BuildContext context) => FeedPage()
      },
      onGenerateRoute: (settings){
        if(settings.name == '/userdetail'){
          final user=settings.arguments as UserData;
          return MaterialPageRoute(builder: (context)=>UserDetailPage(id: user.id,email: user.email, faceData: user.faceData));
        }
      },
    );
  }
}