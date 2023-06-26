import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:face_shield/processors/ConditioChecker.dart';
import 'package:face_shield/processors/FaceProcessor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:face_shield/components/AnimatedText.dart';
import "package:face_shield/services/api.dart" as api;

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
  bool wrongPasswordEntered = false;
  bool isFaceHeld = false;
  Timer? faceHoldTimer;

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
      isBlinking = await widget.faceProcessor.checkEyeBlinkWithCameraImage(image);
    }
    if(mounted) {
      setState(() {
        faceHoldTimer = Timer.periodic(const Duration(seconds: 3), (_) {
          if (isFaceSquared && mounted) {
            setState(() {
              isFaceHeld = true;
            });
          } else {
            if(mounted){
              setState(() {
                isFaceHeld = false;
              });
            }
          }
        });
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
    bool alive = await widget.faceProcessor.checkLiveness(image);
    if(mounted){
      setState(() {
        if(alive) livenessCheck = true;
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
          List<double> data = await widget.faceProcessor.imageToFaceData(path!);
          // Object user = await widget.faceProcessor.findBestMatchingUser(data);

          if (mounted) {
            setState(() {
              personValid = true;
              picturePath = path;
              faceData = data;
              proofOfLifeTesting = false;
            });
          }
        } catch (e) {
          print('Error taking picture: $e');
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('An error occurred while taking a picture: $e'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.pop(context); // Go back to the home page
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
      return true;
    }
    return false;
  }

  Future<bool> logIn() async {
    print("${faceData.length} Inside Login Camera Widget AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    Object result = await widget.faceProcessor.findBestMatchingUserCosine(faceData);
    if(result is bool){
      if(mounted){
        setState(() {
          performedLogin = true;
        });
      }
      return false;
    } else {
      if(mounted) {
        setState(() {
          user = result as Map<String, dynamic>?;
          performedLogin = true;
        });
      }
      return true;
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget body = const Center(child: CircularProgressIndicator());
      if(isInitialized){
        FacePainter facePainter = FacePainter(face: detectedFace, imageSize: widget.cameraProcessor.getImageSize(), maxAngle: 15);
        Visibility painter = Visibility(visible: isPainterVisible, child: CustomPaint(painter: facePainter));
        if (personValid) {
          if(!performedLogin){
            logIn().then((value) {
              if(value){
                Navigator.popAndPushNamed(context, "/confirm", arguments: [picturePath, user?["email"]]);
              } else {
                Navigator.popAndPushNamed(context, "/failedLogin");
              }
            });
          }
        }
        else if(proofOfLifeTesting && !personValid && livenessCheck){
          maxAngle = facePainter.maxAngle;
          body = StreamBuilder<List<bool>>(
              stream: conditionChecker.conditionStream,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  bool result = snapshot.data!.every((element) => element == true);
                  if(result) {
                    if(isFaceSquared){
                      if(isFaceHeld){
                        if(widget.cameraProcessor.isInitialized){
                          takePicture();
                        }
                      } else {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CameraPreview(widget.cameraProcessor.controller),
                            painter
                          ],
                        );
                      }
                    }
                  }
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(widget.cameraProcessor.controller),
                      painter,
                      Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                              padding: const EdgeInsets.all(5.0),
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
      return Scaffold(
        body: Stack(
        fit: StackFit.expand,
          children: [
            body,
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16, left: 16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue, // Choose the desired background color
                ),
                child: IconButton(
                  icon: const Icon(Icons.login),
                  color: Colors.white, // Choose the desired icon color
                  onPressed: () {
                    Navigator.popAndPushNamed(context, "/login2");
                  },
                ),
              ),
            )
          ],
      )
      );
    }
}

