
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:face_shield/components/alertQueue.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:face_shield/processors/FaceProcessor.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

import 'facePainter.dart';

class CameraWidget extends StatefulWidget {

  late final FaceProcessor faceProcessor;
  late final CameraProcessor cameraProcessor;

  CameraWidget({Key? key}) : super(key: key){
    cameraProcessor = CameraProcessor();
    faceProcessor = FaceProcessor();
  }

  @override
  State<StatefulWidget> createState() {
    return CameraWidgetState();
  }
}

class CameraWidgetState extends State<CameraWidget> {

  bool isDetecting = false;
  bool isPainterVisible = false;
  Face? detectedFace;
  CameraImage? faceImage;

  @override
  void initState(){
    super.initState();
    _start();
  }

  Future<List<Face>> getFaces(CameraImage image) async {
    return await widget.faceProcessor.detect(image);
  }

  void detect() async {
    await widget.cameraProcessor.controller.startImageStream((image) async {
      if(isDetecting) return;
      isDetecting = true;
      try {
        List<Face> faces = await getFaces(image);
        if(faces.isNotEmpty){
          setState(()  {
            isPainterVisible = true;
            detectedFace = faces[0];
            faceImage = image;
            //if((detectedFace!.headEulerAngleY! < 2 && detectedFace!.headEulerAngleY! > -2) && (detectedFace!.headEulerAngleX! < 2 && detectedFace!.headEulerAngleX! > -2)){
              //isControllerInitialized = false;
              //widget.cameraProcessor.controller.stopImageStream();
            //}
          });
        } else {
          setState(() {
            isPainterVisible = false;
            detectedFace = null;
          });
        }
        isDetecting = false;
      } catch (e){
        throw Exception('Error in detecting faces');
      }
    });
  }


  void _start()  async {
    await widget.cameraProcessor.initialize();
    setState(() {
      widget.faceProcessor.cameraRotation = widget.cameraProcessor.cameraRotation;
    });
    detect();
  }


  @override
  Widget build(BuildContext context) {
    Visibility painter = Visibility(
        visible: isPainterVisible,
        child: CustomPaint(
            painter: FacePainter(
                face: detectedFace,
                imageSize: widget.cameraProcessor.getImageSize()
            )
        )
    );
      //if(proofOfLifeResult){
        //widget.cameraProcessor.dispose();
        //Future.delayed(const Duration(milliseconds: 50), () => Navigator.popAndPushNamed(context, '/'));
        //body = const Center();
      //}
    return Stack(
      fit: StackFit.expand,
      children: [
        Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(widget.cameraProcessor.controller),
              painter
            ]
        )
      ]
    );
  }
}

