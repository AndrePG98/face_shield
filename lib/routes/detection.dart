import 'package:face_shield/components/cameraBackup.dart';
import 'package:face_shield/components/cameraWidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class DetectionWidget extends StatefulWidget{
  const DetectionWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return DetectionState();
  }

}

class DetectionState extends State<DetectionWidget>{

  CameraWidget cameraWidget = CameraWidget();

  @override
  Widget build(BuildContext context) {
    String username = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          cameraWidget,
        ],
      ),
    );
  }
}
