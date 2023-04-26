import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as IMG;
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceProcessor{
  FaceDetector detector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,enableTracking: true, enableContours: true));

  FaceProcessor();

  bool compareFaces(){
    return true;
  }

  Future<bool> checkLeftEye(String pic) async {
    InputImage img = InputImage.fromFilePath(pic);
    List<Face> faces= await detector.processImage(img);
    //print(faces[0].rightEyeOpenProbability);
    return faces[0].rightEyeOpenProbability! >= 0.9;
    // picture taken is mirrored so we check the other eye
    // we are checking if the eye is closed
  }
  Future<bool> checkRightEye(String pic) async {
    InputImage img = InputImage.fromFilePath(pic);
    List<Face> faces= await detector.processImage(img);
    //print(faces[0].leftEyeOpenProbability);
    return faces[0].leftEyeOpenProbability! >= 0.9;
    // picture taken is mirrored so we check the other eye
    // we are checking if the eye is closed
  }
  Future<bool> checkSmiling(String pic) async {
    InputImage img = InputImage.fromFilePath(pic);
    List<Face> faces= await detector.processImage(img);
    //print(faces[0].smilingProbability!);
    return faces[0].smilingProbability! >= 0.9;
  }
  Future<Face> getFirstFaceFromImage(String pic) async{
    InputImage img = InputImage.fromFilePath(pic);
    List<Face> faceList= await detector.processImage(img);
    return faceList[0];
  }

  IMG.Image cropFaceFromImage(IMG.Image image, Face faceDetected){
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return IMG.copyCrop(image, x.round(), y.round(), w.round(), h.round());
  }
}
