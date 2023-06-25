import 'dart:math';

import 'package:camera/camera.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:face_shield/processors/ConditioChecker.dart';
import 'package:face_shield/processors/FaceProcessor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:face_shield/components/AnimatedText.dart';


import 'facePainter.dart';

class LogInCameraWidget extends StatefulWidget {

  late final FaceProcessor faceProcessor;
  late final CameraProcessor cameraProcessor;

  LogInCameraWidget({Key? key}) : super(key: key){
    cameraProcessor = CameraProcessor();
    faceProcessor = FaceProcessor();
  }

  @override
  State<StatefulWidget> createState() {
    return LogInCameraWidgetState();
  }
}

class LogInCameraWidgetState extends State<LogInCameraWidget> {

  bool isDetecting = false;
  bool isInitialized = false;
  bool isPainterVisible = false;
  bool proofOfLifeTesting = false;
  bool isFaceSquared = false;
  Face? detectedFace;
  CameraImage? faceImage;
  ConditionChecker conditionChecker = ConditionChecker();
  bool isSmiling = false;
  bool isLookingLeft = false;
  bool isLookingRight = false;
  bool isBlinking = false;
  int maxAngle = 20;
  bool livenessCheck = false;
  String picturePath = "";
  Object bestMatchingUser = "";
  List<double> faceData = [];
  Map<String, dynamic>? user;
  bool performedLogin = false;
  bool personValid = false;
  bool? test;

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

  void _resetProofOflifeTesting(){
    if(mounted){
      setState(() {
        conditionChecker.dispose();
        proofOfLifeTesting = false;
        isSmiling = false;
        isLookingLeft = false;
        isLookingRight = false;
        isBlinking = false;
        conditionChecker = ConditionChecker();
      });
    }
  }

  void _proofOfLifeTest(CameraImage image) async {
    if(!isSmiling) {
      isSmiling = await widget.faceProcessor.checkSmiling(image);
    }
    if(!isLookingLeft) {
      isLookingLeft = await widget.faceProcessor.checkLookLeft(image);
    }
    if(!isLookingRight) {
      isLookingRight = await widget.faceProcessor.checkLookRight(image);
    }
    if(!isBlinking){
      isBlinking = await widget.faceProcessor.checkEyeBlink(image);
    }
    if(mounted) {
      setState(() {
        conditionChecker.addConditions([isSmiling, isLookingLeft, isLookingRight, isBlinking]);
      });
    }
  }

  void _isFaceSquared() async {
    if(mounted){
      setState(() {
        isFaceSquared = (detectedFace!.headEulerAngleY! < maxAngle && detectedFace!.headEulerAngleY! > -maxAngle)
            && (detectedFace!.headEulerAngleX! < maxAngle && detectedFace!.headEulerAngleX! > -maxAngle);
        if(isFaceSquared) {
          proofOfLifeTesting = true;
        }
      });
    }
  }

  void _livenessCheck(CameraImage image) async {
    bool moved = await widget.faceProcessor.checkFaceMovement(image);
    if(mounted){
      setState(() {
        if(moved) livenessCheck = true;
      });
    }
  }

  void detect() async {
    if(mounted){
      await widget.cameraProcessor.controller.startImageStream((image) async {
        if(isDetecting) return;
        isDetecting = true;
        List<Face> faces = await getFaces(image);
        if(faces.isNotEmpty){
          if(mounted){
            setState(() {
              isPainterVisible = true;
              detectedFace = faces[0];
              faceImage = image;
            });
            _isFaceSquared();
            if(!livenessCheck && isFaceSquared){
              _livenessCheck(image);
            }
            if(livenessCheck){
              _proofOfLifeTest(image);

            }
          }
        } else { // 0 faces detected
          if(mounted){
            setState(() {
              isPainterVisible = false;
              _resetProofOflifeTesting();
              livenessCheck = false;
            });
          }
        }
        if(mounted){ // loop over
          setState(() {
            isDetecting = false;
            faces = [];
          });
        }
      });
    }
  }

  Future<List<Face>> getFaces(CameraImage image) async {
    return await widget.faceProcessor.detect(image);
  }

  Future<bool> takePicture() async {
    if (widget.cameraProcessor.isInitialized) {
      if (widget.cameraProcessor.controller.value.isStreamingImages) {
        try {
          String? path = await widget.cameraProcessor.takePicture();
          List<double> data = await widget.faceProcessor.imageToFaceData(faceImage!);
          // Object user = await widget.faceProcessor.findBestMatchingUser(data);

          if (mounted) {
            setState(() {
              personValid = true;
              picturePath = path!;
              faceData = data;
              proofOfLifeTesting = false;
              widget.cameraProcessor.dispose();
            });
          }
        } catch (e) {
          print('Error taking picture: $e');
          Navigator.pop(context);
          // Handle the error appropriately, e.g., show an error message
        }
      }
      return true;
    }
    return false;
  }

  Future<bool> logIn() async {
    if(!performedLogin){
      Object result = await widget.faceProcessor.findBestMatchingUser(faceData);
      if(result is bool){
        if(mounted){
          setState(() {
            performedLogin = true;
            testValue(false);
          });
        }
        return false;
      } else {
        if(mounted) {
          setState(() {
            user = result as Map<String, dynamic>?;
            performedLogin = true;
            testValue(true);
          });
        }
        return true;
      }
    }
    return false;
  }

  void testValue(bool value){
    if(mounted){
      setState(() {
        test = value;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget body = const Center(child: CircularProgressIndicator());
      if(isInitialized){
        FacePainter facePainter = FacePainter(face: detectedFace, imageSize: widget.cameraProcessor.getImageSize(), maxAngle: 15);
        Visibility painter = Visibility(visible: isPainterVisible, child: CustomPaint(painter: facePainter));
        if(personValid) {
          logIn();
          body = Center(child: Align(alignment: Alignment.center, child: Text("Performed Login : $performedLogin, Login result : $test, User: ${user?["email"]}")));
        }else if(proofOfLifeTesting && !personValid){
          maxAngle = facePainter.maxAngle;
          body = StreamBuilder<List<bool>>(
              stream: conditionChecker.conditionStream,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  bool result = snapshot.data!.every((element) => element == true);
                  if(result) {
                    if(isFaceSquared){
                      takePicture();
                    }
                    /*if(isFaceSquared && mounted && picturePath.isEmpty){
                      takePicture();
                    }
                    if(picturePath.isNotEmpty && !performedLogin){
                      logIn();
                    }
                    if(performedLogin && user != null && picturePath.isNotEmpty){
                      *//*Future.delayed(const Duration(milliseconds: 250), () {
                        Navigator.popAndPushNamed(context, "/feed", arguments: [picturePath, user]);
                      });*//*
                    } else {
                      return Center(child: Text("Performed Login : $performedLogin, Picture Path Length : ${picturePath.length}, User: ${user?["email"]}"));
                    }*/
                  }
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(widget.cameraProcessor.controller),
                      painter,
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedText(value: isSmiling, label: "Smile"),
                                  AnimatedText(value: isLookingLeft, label: "Look Left"),
                                  AnimatedText(value: isLookingRight, label: "Look Right"),
                                  AnimatedText(value: isBlinking, label: "Blink"),
                                ],
                              )
                          )
                      )
                    ],
                  );
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(widget.cameraProcessor.controller),
                    painter
                  ],
                );
              }
          );
        } else {
          body = Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(widget.cameraProcessor.controller),
              painter
            ],
          );
        }
      } else {
        body = const Center(child: CircularProgressIndicator());
      }
      return Stack(
          fit: StackFit.expand,
          children: [body]
      );
    }
}

