import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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
  Image? pic1; //for displaying
  Image? pic2;
  XFile? file1;//for processing everything with faceProcessor
  XFile? file2;
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
            Positioned(// left pic
              left: 30,
              bottom: 20,
              child: FloatingActionButton(
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
              bottom: 700,
              left: 30,
              child: FloatingActionButton(
                onPressed: () async {bool result = await faceProcessor.compareFaces(file1!,file2!);print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.compare,
                  size: 40,
                ),
              ),
            ),
            Positioned( // left eye button
              bottom: 560,
              left: 30,
              child: FloatingActionButton(
                onPressed: () async {bool result = await faceProcessor.checkLeftEye(file1!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.panorama_fish_eye,
                  size: 40,
                ),
              ),
            ),
            Positioned( // left look button
              bottom: 490,
              left: 30,
              child: FloatingActionButton(
                onPressed: () async {bool result = await faceProcessor.checkLookLeft(file1!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_left,
                  size: 40,
                ),
              ),
            ),
            Positioned( // up look button
              bottom: 420,
              left: 30,
              child: FloatingActionButton(
                onPressed: () async {bool result = await faceProcessor.checkLookUp(file1!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  size: 40,
                ),
              ),
            ),
            Positioned( // checkSmilingAndLeftEye button
              bottom: 630,
              left: 30,
              child: FloatingActionButton(
                onPressed: () async {bool result = await faceProcessor.checkSmilingAndLeftEye(file1!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.query_stats,
                  size: 40,
                ),
              ),
            ),
            Positioned( //checkSmiling button
              bottom: 700,
              right: 30,
              child: FloatingActionButton(
                onPressed: () async {bool result = await faceProcessor.checkSmiling(file1!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insert_emoticon_rounded,
                  size: 40,
                ),
              ),
            ),
            Positioned( // checkSmilingAndRightEye
              bottom: 630,
              right: 30,
              child: FloatingActionButton(
                onPressed: () async {bool result = await faceProcessor.checkSmilingAndRightEye(file1!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.track_changes_outlined,
                  size: 40,
                ),
              ),
            ),
            Positioned( // right eye button
              bottom: 560,
              right: 30,
              child: FloatingActionButton(  /*faceProcessor.compareFaces()*/
                onPressed: () async {bool result = await faceProcessor.checkRightEye(file1!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.panorama_fish_eye,
                  size: 40,
                ),
              ),
            ),
            Positioned( // look right button
              bottom: 490,
              right: 30,
              child: FloatingActionButton(  /*faceProcessor.compareFaces()*/
                onPressed: () async {bool result = await faceProcessor.checkLookRight(file1!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_right,
                  size: 40,
                ),
              ),
            ),
            Positioned( // look down button
              bottom: 420,
              right: 30,
              child: FloatingActionButton(  /*faceProcessor.compareFaces()*/
                onPressed: () async {bool result = await faceProcessor.checkLookDown(file1!); print(result);},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  size: 40,
                ),
              ),
            ),
            Positioned( // right pic
              bottom: 20,
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
        XFile image = await controller!.takePicture();
          if(bool){
            file1 = image;
            pic1 = Image.file(File(image.path));
            //image1 = await faceProcessor.xFileToImage(image);
            setState(() {});
            return;
          }
          file2 = image;
          pic2 = Image.file(File(image.path));
          //image2 = await faceProcessor.xFileToImage(image);
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

