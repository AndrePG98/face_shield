import 'package:face_shield/components/LogInCameraWidget.dart';
import 'package:face_shield/components/SignUpCameraWidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class SignUpDetectionWidget extends StatefulWidget{

  SignUpDetectionWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return SignUpDetectionState();
  }

}

class SignUpDetectionState extends State<SignUpDetectionWidget>{


  Future<List<String>> _fetchData() async {
    List<String> userInfo = ModalRoute.of(context)?.settings.arguments as List<String>;
    return userInfo;
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
                  snapshot.error.toString(),
                style: TextStyle(fontSize: 10),
              )
          );
        } else {
          final List args = snapshot.data ?? [];
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                SignUpCameraWidget(userList: args),
              ],
            ),
          );
        }
      },
    );
  }
}
