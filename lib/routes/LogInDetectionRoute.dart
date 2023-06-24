import 'package:face_shield/components/LogInCameraWidget.dart';
import 'package:face_shield/components/SignUpCameraWidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class LogInDetectionWidget extends StatefulWidget{

  LogInDetectionWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return LogInDetectionState();
  }

}

class LogInDetectionState extends State<LogInDetectionWidget>{

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          LogInCameraWidget()
        ],
      ),
    );
  }
}
