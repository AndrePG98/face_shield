
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
  Map<String, bool> promptsMap = {'promptingSmile' : false, 'promptingLookLeft' : false, 'promptingLookRight' : false};
  bool viable = false;

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
  bool isInitialized = false;
  bool isPainterVisible = false;
  Face? detectedFace;
  CameraImage? faceImage;

  @override
  void dispose(){
    widget.cameraProcessor.dispose();
    super.dispose();
  }

  @override
  void initState(){
    _start();
    super.initState();
  }

  void _start()  async {
    if(mounted){
      await widget.cameraProcessor.initialize();
      setState(() {
        isInitialized = widget.cameraProcessor.isInitialized;
        widget.faceProcessor.cameraRotation = widget.cameraProcessor.cameraRotation;
      });
      detect();
    }
  }

  void detect() async {
    await widget.cameraProcessor.controller.startImageStream((image) async {
      if(isDetecting) return;
      isDetecting = true;
      List<Face> faces = await getFaces(image);
      if(faces.isNotEmpty){
        detectedFace = faces[0];
        faceImage = image;
        if(mounted){
          setState(()  {
            isPainterVisible = true;
            if((detectedFace!.headEulerAngleY! < 20 && detectedFace!.headEulerAngleY! > -20) && (detectedFace!.headEulerAngleX! < 20 && detectedFace!.headEulerAngleX! > -20)){
              widget.viable = true;
              //isControllerInitialized = false;
              //widget.cameraProcessor.controller.stopImageStream();
            } else {
              widget.viable = false;
            }
          });
        }
      } else {
        if(mounted){
          setState(() {
            isPainterVisible = false;
            widget.viable = false;
          });
        }
      }
      isDetecting = false;
      detectedFace = null;
      faceImage = null;
      faces = [];
    });
  }

  Future<List<Face>> getFaces(CameraImage image) async {
    return await widget.faceProcessor.detect(image);
  }


  @override
  Widget build(BuildContext context) {
    Widget body;
    Visibility painter;
    if(isInitialized){
      painter = Visibility(
          visible: isPainterVisible,
          child: CustomPaint(
              painter: FacePainter(
                  face: detectedFace,
                  imageSize: widget.cameraProcessor.getImageSize()
              )
          )
      );
      body = Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(widget.cameraProcessor.controller),
          //painter,
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: FloatingActionButton(
                  backgroundColor: widget.viable ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  child: widget.viable ? const FaIcon(FontAwesomeIcons.check) : const FaIcon(FontAwesomeIcons.xmark),
                  onPressed: (){},
                )
            ),
          )
        ],
      );
    } else {
      body = const Center(child: CircularProgressIndicator());
    }
      //if(proofOfLifeResult){
        //widget.cameraProcessor.dispose();
        //Future.delayed(const Duration(milliseconds: 50), () => Navigator.popAndPushNamed(context, '/'));
        //body = const Center();
      //}
    return Stack(
      fit: StackFit.expand,
      children: [
        Stack(fit: StackFit.expand, children: [body])
      ]
    );
  }
}

