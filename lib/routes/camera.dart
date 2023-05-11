import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_shield/models/CameraProcessor.dart';
import 'package:face_shield/models/FaceProcessor.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:math';

import '../components/facePainter.dart';

class CameraPage extends StatefulWidget {
  final FaceProcessor faceProcessor;
  final CameraProcessor cameraProcessor;
  const CameraPage({Key? key, required this.faceProcessor, required this.cameraProcessor}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CameraPageState();
  }
}

class CameraPageState extends State<CameraPage> {
  Size? imageSize;
  Face? detectedFace;
  String? faceFilePath;
  bool isInitializing = true;
  bool isDetecting = false;

  @override
  void initState(){
    super.initState();
    _start();

  }

  void _start() async {
    await widget.cameraProcessor.initialize();
    setState(() {
      isInitializing = false;
    });
    imageSize = widget.cameraProcessor.getImageSize();

    widget.cameraProcessor.controller?.startImageStream((image) async {
      if (widget.cameraProcessor.controller != null) {
        if(isDetecting) return;
        isDetecting = true;
        Face face =  await widget.faceProcessor.getFirstFaceFromImage(image);
        await widget.cameraProcessor.controller?.stopImageStream();
        XFile? file = await widget.cameraProcessor.takePicture();
        setState(() {
          detectedFace = face;
          faceFilePath = file?.path;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double mirror = pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    late Widget body;
    if (isInitializing) {
      body = const Center( child: CircularProgressIndicator());
    }
    if (!isInitializing && detectedFace != null){
      body = AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          padding: const EdgeInsets.all(16),
          child: Text("$isInitializing ${detectedFace==null}")
        ),
      );
    } else {
      body = Transform.scale(
        scale: 1.0,
        child: AspectRatio(
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: SizedBox(
                width: width,
                height: width * widget.cameraProcessor.controller!.value.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreview(widget.cameraProcessor.controller!),
                    CustomPaint(
                      painter: FacePainter(face: detectedFace, imageSize: imageSize!),
                    ),
                    Text("$isInitializing ${detectedFace==null}")
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(body: body);
  }

}

