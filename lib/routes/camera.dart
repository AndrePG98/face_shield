import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:face_shield/processors/FaceProcessor.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

import '../components/facePainter.dart';

class CameraPage extends StatefulWidget {

  late final FaceProcessor faceProcessor;
  late final CameraProcessor cameraProcessor;

  CameraPage({Key? key}) : super(key: key){
    cameraProcessor = CameraProcessor();
    faceProcessor = FaceProcessor();
  }

  @override
  State<StatefulWidget> createState() {
    return CameraPageState();
  }
}

class CameraPageState extends State<CameraPage> {

  bool isControllerInitialized = false;
  bool isDetecting = false;
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
      widget.faceProcessor.cameraRotation = widget.cameraProcessor.cameraRotation;
    });
    await widget.cameraProcessor.controller.startImageStream((image) async {
      if(isDetecting) return;
      isDetecting = true;
      try {
        List<Face> faces = await widget.faceProcessor.detect(image);
        if(faces.isNotEmpty){
          setState(() {
            faceDetected = true;
            detectedFace = faces[0];
          });
        }
        //if(await widget.faceProcessor.isFaceDetected(image)){
          //Face face = await widget.faceProcessor.getFirstFaceFromImage(image);
          //print("Detected face : $face");
         // img.Image croppedImage = await widget.faceProcessor.cropFaceFromImage(image);
          //bool test = await widget.faceProcessor.checkLeftEye(image);
          //setState(() {
            //faceDetected = true;
            //proofOfLifeTest = test;
            //detectedFace = face;
            //faceImage = croppedImage;
          //});
        //}
        isDetecting = false;
      } catch (e){
        throw Exception('Error in detecting faces');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if(isControllerInitialized){
      body = Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(widget.cameraProcessor.controller),
          CustomPaint(
            painter: FacePainter(
                face: detectedFace,
                imageSize: widget.cameraProcessor.getImageSize()
            ),
          )
        ],
      );
    } else {
      body = const CircularProgressIndicator();
    }
    return Scaffold(
        body: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              body,
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.cameraProcessor.dispose();
                    },
                    icon: const FaIcon(FontAwesomeIcons.faceAngry, size: 50,)
                ),
              )
            ],
          )
        )
    );
  }
}

