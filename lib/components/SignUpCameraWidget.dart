import 'dart:async';
import 'package:camera/camera.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:face_shield/processors/FaceProcessor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:face_shield/services/api.dart' as api;

import 'facePainter.dart';

class SignUpCameraWidget extends StatefulWidget {
  late final FaceProcessor faceProcessor;
  late final CameraProcessor cameraProcessor;
  late final List userInfo;

  SignUpCameraWidget({Key? key, required List userList}) : super(key: key) {
    cameraProcessor = CameraProcessor();
    faceProcessor = FaceProcessor();
    userInfo = userList;
  }

  @override
  State<StatefulWidget> createState() {
    return SignUpCameraWidgetState();
  }
}

class SignUpCameraWidgetState extends State<SignUpCameraWidget> {
  bool isDetecting = false;
  bool isInitialized = false;
  bool isPainterVisible = false;
  bool isFaceSquared = false;
  Face? detectedFace;
  CameraImage? faceImage;
  int maxAngle = 15;
  String picturePath = "";
  bool tookPicture = false;
  Object bestMatchingUser = "";
  List<double> faceData = [];
  Object? signUpResult;
  bool performedSignUp = false;
  bool isFaceHeld = false;
  Timer? faceHoldTimer;

  @override
  void dispose() {
    widget.cameraProcessor.dispose();
    faceHoldTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _start();
    super.initState();
    faceHoldTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (isFaceSquared) {
        setState(() {
          isFaceHeld = true;
        });
      } else {
        setState(() {
          isFaceHeld = false;
        });
      }
    });
  }

  void _start() async {
    if (mounted) {
      await widget.cameraProcessor.initialize();
      setState(() {
        isInitialized = widget.cameraProcessor.isInitialized;
        widget.faceProcessor.cameraRotation =
            widget.cameraProcessor.cameraRotation;
      });
      detect();
    }
  }

  void _isFaceSquared() async {
    if (mounted) {
      setState(() {
        isFaceSquared = (detectedFace!.headEulerAngleY! < maxAngle &&
                detectedFace!.headEulerAngleY! > -maxAngle) &&
            (detectedFace!.headEulerAngleX! < maxAngle &&
                detectedFace!.headEulerAngleX! > -maxAngle);
      });
    }
  }

  void detect() async {
    if (mounted) {
      await widget.cameraProcessor.controller.startImageStream((image) async {
        if (isDetecting) return;
        isDetecting = true;
        List<Face> faces = await getFaces(image);
        if (faces.isNotEmpty) {
          if (mounted) {
            setState(() {
              isPainterVisible = true;
              detectedFace = faces[0];
              faceImage = image;
            });
            _isFaceSquared();
          }
        } else {
          // 0 faces detected
          if (mounted) {
            setState(() {
              isPainterVisible = false;
            });
          }
        }
        if (mounted) {
          // loop over
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

  void updateFaceData() async {
    if (faceData.isEmpty) {
      List<double> data =
          await widget.faceProcessor.imageToFaceData(picturePath);
      faceData = data;
    }
  }

  Future<void> signUp(String email, String password) async {
    updateFaceData();
    if (!performedSignUp && faceData.isNotEmpty) {
      Object result = await api.signUp(email, password, faceData);
      if (result is bool) {
        if (mounted) {
          setState(() {
            signUpResult = result;
            performedSignUp = true;
          });
        }
      }
      if (signUpResult != null) {
        showSignUpDialog(result);
      }
    }
  }

  Future<bool> takePicture() async {
    if (widget.cameraProcessor.isInitialized) {
      if (widget.cameraProcessor.controller.value.isStreamingImages) {
        try {
          String? path = await widget.cameraProcessor.takePicture();

          if (mounted) {
            setState(() {
              picturePath = path!;
              tookPicture = true;
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
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return false;
        }
      }
      return true;
    }
    return false;
  }

  void showSignUpDialog(Object signUpSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (signUpSuccess is bool && signUpSuccess == true) {
          return AlertDialog(
            title: const Text('Sign Up Successful'),
            content: Text("Signed up as ${widget.userInfo[0]}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('Sign Up Failed'),
            content: Text("$signUpResult"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body = const Center(child: CircularProgressIndicator());
    if (isInitialized) {
      if (tookPicture) {
        if (!performedSignUp) {
          signUp(widget.userInfo[0], widget.userInfo[1]);
        }
      } else {
        if (isFaceSquared) {
          if (!isFaceHeld) {
            Visibility painter = Visibility(
                visible: isPainterVisible,
                child: CustomPaint(
                    painter: FacePainter(
                        face: detectedFace,
                        imageSize: widget.cameraProcessor.getImageSize(),
                        maxAngle: maxAngle)));
            body = Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(widget.cameraProcessor.controller),
                painter
              ],
            );
          } else {
            if (!performedSignUp && isFaceHeld && !tookPicture) {
              if (widget.cameraProcessor.isInitialized) {
                takePicture();
              }
            }
          }
        } else {
          Visibility painter = Visibility(
              visible: isPainterVisible,
              child: CustomPaint(
                  painter: FacePainter(
                      face: detectedFace,
                      imageSize: widget.cameraProcessor.getImageSize(),
                      maxAngle: maxAngle)));
          body = Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(widget.cameraProcessor.controller),
              painter
            ],
          );
        }
      }
    } else {
      body = const Center(child: CircularProgressIndicator());
    }
    return Stack(fit: StackFit.expand, children: [
      body,
    ]);
  }
}
