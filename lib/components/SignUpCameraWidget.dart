import 'package:camera/camera.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:face_shield/processors/ConditioChecker.dart';
import 'package:face_shield/processors/FaceProcessor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:face_shield/components/AnimatedText.dart';
import 'package:face_shield/services/api.dart' as api;


import 'facePainter.dart';

class SignUpCameraWidget extends StatefulWidget {

  late final FaceProcessor faceProcessor;
  late final CameraProcessor cameraProcessor;
  late final List userInfo;

  SignUpCameraWidget({Key? key, required List userList}) : super(key: key){
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
  Object bestMatchingUser = "";
  List<double> faceData = [];
  bool signUpResult = false;


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


  void _isFaceSquared() async {
    if(mounted){
      setState(() {
        isFaceSquared = (detectedFace!.headEulerAngleY! < maxAngle && detectedFace!.headEulerAngleY! > -maxAngle)
            && (detectedFace!.headEulerAngleX! < maxAngle && detectedFace!.headEulerAngleX! > -maxAngle);
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
          }
        } else { // 0 faces detected
          if(mounted){
            setState(() {
              isPainterVisible = false;
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

  void updateFaceData() async {
    if(faceData.isEmpty){
      List<double> data = await widget.faceProcessor.imageToFaceData(faceImage!);

      if (mounted) {
        setState(() {
          faceData = data;
        });
      }
    }
  }

  void signUp(String email, String password, List<double> faceData) async {
    bool result = await api.signUp(email, password, faceDataList:  faceData);
    if(mounted) {
        setState(() {
        signUpResult = result;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget body;
    if(mounted){
      if(isInitialized){
        if(isFaceSquared){
          updateFaceData();
          signUp(widget.userInfo[0], widget.userInfo[1], faceData);
          if(signUpResult){
            widget.cameraProcessor.dispose();
            Future.delayed(const Duration(milliseconds: 500), () => Navigator.popAndPushNamed(context, '/'));
            body = const Center(child: CircularProgressIndicator());
          } else {
            Future.delayed(const Duration(milliseconds: 500), () => Navigator.popAndPushNamed(context, '/'));
            body = Center(child: Text("$signUpResult"));

          }
        } else {
          Visibility painter = Visibility(
              visible: isPainterVisible,
              child: CustomPaint(
                  painter: FacePainter(
                      face: detectedFace,
                      imageSize: widget.cameraProcessor.getImageSize(),
                      maxAngle: maxAngle
                  )
              )
          );
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
    return const Center();
  }
}

