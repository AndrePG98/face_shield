import 'package:face_shield/components/cameraWidget.dart';
import 'package:flutter/cupertino.dart';

class DetectionWidget extends StatefulWidget{
  const DetectionWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return DetectionState();
  }

}

class DetectionState extends State<DetectionWidget>{
  @override
  Widget build(BuildContext context) {
    String username = ModalRoute.of(context)!.settings.arguments as String;
    return CameraWidget();
  }


}
