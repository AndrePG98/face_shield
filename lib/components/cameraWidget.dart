
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:face_shield/components/alertQueue.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:face_shield/processors/ConditioChecker.dart';
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
  final Map<String, bool> promptsMap = {'promptingSmile' : false, 'promptingLookLeft' : false, 'promptingLookRight' : false};

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
  bool proofOfLifeTesting = false;
  Face? detectedFace;
  CameraImage? faceImage;
  ConditionChecker conditionChecker = ConditionChecker();
  bool isSmiling = false;
  bool isLookingLeft = false;
  bool isLookingRight = false;


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
        if(mounted){
          setState(() {
            isPainterVisible = true;
            detectedFace = faces[0];
            faceImage = image;
          });
          if(proofOfLifeTesting){
            if(!isSmiling) isSmiling = await widget.faceProcessor.checkSmiling(image);
            if(!isLookingLeft) isLookingLeft = await widget.faceProcessor.checkLookLeft(image);
            if(!isLookingRight) isLookingRight = await widget.faceProcessor.checkLookRight(image);
            setState(() {
              conditionChecker.checkConditions([isSmiling, isLookingLeft, isLookingRight]);
            });
          } else {
            if(mounted){
              setState(()  {
                if((detectedFace!.headEulerAngleY! < 20 && detectedFace!.headEulerAngleY! > -20) && (detectedFace!.headEulerAngleX! < 20 && detectedFace!.headEulerAngleX! > -20)){
                  proofOfLifeTesting = true;
                }
              });
            }
          }
        }
      } else {
        if(mounted){
          setState(() {
            isPainterVisible = false;
          });
        }
      }
      if(mounted){
        setState(() {
          isDetecting = false;
          faces = [];
        });
      }
    });
  }

  Future<List<Face>> getFaces(CameraImage image) async {
    return await widget.faceProcessor.detect(image);
  }


  @override
  Widget build(BuildContext context) {
    Widget body;
    if(isInitialized){
     Visibility painter = Visibility(
          visible: isPainterVisible,
          child: CustomPaint(
              painter: FacePainter(
                  face: detectedFace,
                  imageSize: widget.cameraProcessor.getImageSize()
              )
          )
      );
     if(proofOfLifeTesting){
       body = StreamBuilder<List<bool>>(
         stream: conditionChecker.conditionStream,
         builder: (context, snapshot) {
           if(snapshot.hasData){
            bool result = snapshot.data!.every((element) => element == true);
            if(result) {
              widget.cameraProcessor.dispose();
              Future.delayed(const Duration(milliseconds: 50), () => Navigator.popAndPushNamed(context, '/feed'));
              return const Center();
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(widget.cameraProcessor.controller),
                painter,
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(value: isSmiling, onChanged: null,),
                      Checkbox(value: isLookingLeft, onChanged: null),
                      Checkbox(value: isLookingRight, onChanged: null)
                    ],
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

