import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'FaceProcessor.dart';
import 'package:image/image.dart' as img;



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
  String? pic1path; //for processing
  String? pic2path;
  img.Image? image1;
  img.Image? image2;
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
                onPressed: () async {bool result = await _compareFaces(image1!,image2!);print(result);},
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
                onPressed: () async {bool result = await faceProcessor.checkLeftEye(pic1path!); print(result);},
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
                onPressed: () async {bool result = await faceProcessor.checkLookLeft(pic1path!); print(result);},
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
                onPressed: () async {bool result = await faceProcessor.checkLookUp(pic1path!); print(result);},
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
                onPressed: () async {bool result = await faceProcessor.checkSmilingAndLeftEye(pic1path!); print(result);},
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
            Positioned( // checkSmilingAndRightEye
              bottom: 630,
              right: 30,
              child: FloatingActionButton(
                onPressed: () async {bool result = await faceProcessor.checkSmilingAndRightEye(pic1path!); print(result);},
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
                onPressed: () async {bool result = await faceProcessor.checkRightEye(pic1path!); print(result);},
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
                onPressed: () async {bool result = await faceProcessor.checkLookRight(pic1path!); print(result);},
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
                onPressed: () async {bool result = await faceProcessor.checkLookDown(pic1path!); print(result);},
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
            pic1path = image.path;
            pic1 = Image.file(File(image.path));
            image1 = await faceProcessor.xFileToImage(image);
            setState(() {});
            return;
          }
          pic2path = image.path;
          pic2 = Image.file(File(image.path));
          image2 = await faceProcessor.xFileToImage(image);
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
  Future<bool> _compareFaces(img.Image image1,img.Image image2) async{
    List _temp1 = await faceProcessor.imageToFaceData(image1,
        await faceProcessor.getFirstFaceFromImage(pic1path!), pic1path!);
    List _temp2 = await faceProcessor.imageToFaceData(image2,
        await faceProcessor.getFirstFaceFromImage(pic2path!), pic2path!);
    return faceProcessor.compareFaces(_temp1, _temp2);
  }
}

