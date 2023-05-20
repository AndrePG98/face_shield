
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

class CameraBackup extends StatefulWidget {

  late final FaceProcessor faceProcessor;
  late final CameraProcessor cameraProcessor;

  CameraBackup({Key? key}) : super(key: key){
    cameraProcessor = CameraProcessor();
    faceProcessor = FaceProcessor();
  }

  @override
  State<StatefulWidget> createState() {
    return CameraBackupState();
  }
}

class CameraBackupState extends State<CameraBackup> {

  bool isPromptingUser = false;
  bool proofOfLifeResult = false;
  bool isControllerInitialized = false;
  bool isDetecting = false;
  bool isPainterVisible = false;
  Face? detectedFace;
  CameraImage? faceImage;
  bool faceDetected = false;
  Map<String, bool> proofOfLifeMap = {'isSmiling' :  false, 'isLookingLeft' : false, 'isLookingRight' : false};

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
          if(isPromptingUser){
            if(!proofOfLifeMap['isSmiling']!){
              bool smilingResult = await widget.faceProcessor.checkSmiling(image);
              setState(() {
                proofOfLifeMap['isSmiling'] = smilingResult;
              });
            }
            if(!proofOfLifeMap['isLookingLeft']!){
              bool lookLeftResult = await widget.faceProcessor.checkLookLeft(image);
              setState(() {
                proofOfLifeMap['isLookingLeft'] = lookLeftResult;
              });
            }
            if(!proofOfLifeMap['isLookingRight']!){
              bool lookRightResult = await widget.faceProcessor.checkLookRight(image);
              setState(() {
                proofOfLifeMap['isLookingRight'] = lookRightResult;
              });
            }
            if(proofOfLifeMap['isSmiling']! && proofOfLifeMap['isLookingLeft']! && proofOfLifeMap['isLookingRight']!){
              setState(() {
                proofOfLifeResult = true;
              });
            }
          }
          setState(()  {
            detectedFace = faces[0];
            if((detectedFace!.headEulerAngleY! < 20 && detectedFace!.headEulerAngleY! > -20) && (detectedFace!.headEulerAngleX! < 20 && detectedFace!.headEulerAngleX! > -20)){
              setState(() {
                isPainterVisible = true;
                faceDetected = true;
                isPromptingUser = true;
                if(proofOfLifeResult){
                  faceImage = image;
                  isControllerInitialized = false;
                  widget.cameraProcessor.controller.stopImageStream();
                }
              });
            }
          });
        } else {
          setState(() {
            isPainterVisible = false;
            detectedFace = null;
            isPromptingUser = false;
          });
        }
        setState(() {
          isDetecting = false;
        });
      } catch (e){
        throw Exception('Error in detecting faces');
      }
    });
  }

  Future<bool> _onWillPop() async {
    widget.cameraProcessor.dispose();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    String username = ModalRoute.of(context)!.settings.arguments as String;
    Widget body;
    Widget painter = isPainterVisible ? CustomPaint(
      painter: FacePainter(
          face: detectedFace,
          imageSize: widget.cameraProcessor.getImageSize()
      ),
    ) : const Center();
    if(isControllerInitialized){
      body = Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(widget.cameraProcessor.controller),
          painter,
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
                "Prompting : $isPromptingUser, "
                "isSmiling : ${proofOfLifeMap['isSmiling']} , "
                "lookLeft : ${proofOfLifeMap['isLookingLeft']} "
                "lookRight : ${proofOfLifeMap['isLookingRight']}",
                style: const TextStyle(fontSize: 15)),
          )
        ],
      );
    } else {
      if(proofOfLifeResult){
        widget.cameraProcessor.dispose();
        Future.delayed(const Duration(milliseconds: 50), () => Navigator.popAndPushNamed(context, '/'));
        body = const Center();
      }
      body = const CircularProgressIndicator();
    }
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: Center(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    body
                  ],
                )
            )
        ));
  }
}

