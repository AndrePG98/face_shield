import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/src/image.dart' as IMG;
import 'FaceProcessor.dart';



void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{

  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  Image? pic1;
  Image? pic2;
  String? pic1path;
  String? pic2path;
  FaceProcessor faceProcessor = FaceProcessor();

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: Container(
                        child: controller == null?
                        const Center(child:Text("Loading Camera...")):
                        !controller!.value.isInitialized?
                        const Center(
                          child: CircularProgressIndicator(),
                        ):
                        CameraPreview(controller!)
                    )
                ),
                Expanded(
                    child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: Container( // pic1
                            //color: Colors.blue,
                            child: Center(child: pic1 ?? const Text("No image captured")),
                          )
                      ),
                      Expanded(
                          child: Container( // pic2
                            //color: Colors.green,
                            child: Center(child: pic2 ?? const Text("No image captured")),
                          )
                      )
                    ],
                  )
                )
              ],
            ),
          ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 30,
              bottom: 600,
              child: FloatingActionButton( // left pic
                onPressed: (){
                  try{
                    takePic(true);
                  }
                  catch (e){
                    print(e);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera,
                  size: 40,
                ),
              ),
            ),
            Positioned( // compare button
              bottom: 500,
              left: 30,
              child: FloatingActionButton(
                onPressed: () {faceProcessor.compareFaces();},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.compare,
                  size: 40,
                ),
              ),
            ),
            Positioned( // compare button
              bottom: 400,
              left: 30,
              child: FloatingActionButton(
                onPressed: () async {bool result = await faceProcessor.checkLeftEye(pic1path!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_circle_left,
                  size: 40,
                ),
              ),
            ),
            Positioned( // compare button
              bottom: 500,
              right: 30,
              child: FloatingActionButton(  /*faceProcessor.compareFaces()*/
                onPressed: () async {bool result = await faceProcessor.checkSmiling(pic1path!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insert_emoticon_rounded,
                  size: 40,
                ),
              ),
            ),
            Positioned( // compare button
              bottom: 400,
              right: 30,
              child: FloatingActionButton(  /*faceProcessor.compareFaces()*/
                onPressed: () async {bool result = await faceProcessor.checkRightEye(pic1path!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_circle_right,
                  size: 40,
                ),
              ),
            ),
            Positioned( // right pic
              bottom: 600,
              right: 30,
              child: FloatingActionButton(
                onPressed: (){
                  try{
                    takePic(false);
                  }
                  catch (e){
                    print(e);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera,
                  size: 40,
                ),
              ),
            )
          ],
        )
      ),
    );
  }


  void takePic(bool bool) async{
    if(controller != null){
      if(controller!.value.isInitialized){
        var image = await controller!.takePicture();
          if(bool){
            pic1path = image.path;
            pic1 = Image.file(File(image.path));
            setState(() {});
            return;
          }
          pic2path = image.path;
          pic2 = Image.file(File(image.path));
          setState(() {});
          return;
      }
    }
  }

  loadCamera() async {
    cameras = await availableCameras();
    if(cameras != null){
      controller = CameraController(cameras![1], ResolutionPreset.max,enableAudio: false);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        controller?.setFlashMode(FlashMode.auto);
        setState(() {});
      });
    }else{
      print("NO any camera found");
    }
  }

}

