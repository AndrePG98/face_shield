import 'package:camera/camera.dart';
import 'package:face_shield/models/CameraProcessor.dart';
import 'package:face_shield/models/FaceProcessor.dart';
import 'package:flutter/material.dart';

import '../components/facePainter.dart';

class CameraPage extends StatefulWidget {
  final FaceProcessor faceProcessor;
  final CameraProcessor cameraProcessor;
  const CameraPage({Key? key, required this.faceProcessor, required this.cameraProcessor}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CameraPageState();
  }
}

class CameraPageState extends State<CameraPage> {

  @override
  void initState(){
    super.initState();

  }

  void initiate() async {
    await widget.cameraProcessor.initialize();
    Size imageSize = widget.cameraProcessor.getImageSize();

    widget.cameraProcessor.controller?.startImageStream((image) async {
      if (widget.cameraProcessor.controller != null) {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

}

