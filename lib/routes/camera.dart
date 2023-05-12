import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:face_shield/models/CameraProcessor.dart';
import 'package:face_shield/models/FaceProcessor.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

import '../components/facePainter.dart';

class CameraPage extends StatefulWidget {

  late final FaceProcessor faceProcessor;
  late final CameraProcessor cameraProcessor;

  CameraPage({Key? key}) : super(key: key){
    cameraProcessor = CameraProcessor();
    faceProcessor = FaceProcessor(cameraProcessor);
  }

  @override
  State<StatefulWidget> createState() {
    return CameraPageState();
  }
}

class CameraPageState extends State<CameraPage> {

  bool isControllerInitialized = false;
  bool faceDetected = false;
  Face? detectedFace;
  img.Image? faceImage;

  @override
  void initState(){
    _start();
    super.initState();
  }

  void _start()  async {
    await widget.cameraProcessor.initialize();
    setState(() {
      isControllerInitialized = widget.cameraProcessor.isInitialized;
    });
    await widget.cameraProcessor.controller.startImageStream((image) async {
      try {
        if(await widget.faceProcessor.isFaceDetected(image)){
          faceDetected = true;
          Face face = await widget.faceProcessor.getFirstFaceFromImage(image);
          img.Image croppedImage = await widget.faceProcessor.cropFaceFromImage(image);
          setState(() {
            detectedFace = face;
            faceImage = croppedImage;
          });
        }
      } catch (e){
        throw Exception('Error in detecting faces');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if(faceDetected){
        final bytes = Uint8List.fromList(img.encodePng(faceImage!));
        body = Image.memory(bytes, width: 200, height: 200);
      } else {
        body = const Text('No face');
      }
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isControllerInitialized ? CameraPreview(widget.cameraProcessor.controller) : const CircularProgressIndicator(),
              body
            ],
          ),
        )
    );
  }
}

