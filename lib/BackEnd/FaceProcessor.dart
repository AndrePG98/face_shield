import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:flutter/material.dart';

class FaceProcessor{
  double threshold = 0.6; // threshold for face recognition (euclidean distance)
  FaceDetector detector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,enableTracking: true, enableContours: true));
  Delegate? _delegate;
  InterpreterOptions? _options;
  Interpreter? _interpreter;

  FaceProcessor();


  Future<Face> fromImgToFace(String pic) async{
    InputImage img = InputImage.fromFilePath(pic);
    List<Face> faces= await detector.processImage(img);
    return faces[0];
  }
  Future<bool> checkLeftEye(String pic) async {
    Face _face = await fromImgToFace(pic);
    //print(_face.rightEyeOpenProbability);
    return !(_face.rightEyeOpenProbability! >= 0.9);
    // picture taken is mirrored so we check the other eye
    // we are checking if the eye is closed
  }
  Future<bool> checkRightEye(String pic) async {
    Face _face = await fromImgToFace(pic);
    //print(_face.leftEyeOpenProbability);
    return !(_face.leftEyeOpenProbability! >= 0.9);
    // picture taken is mirrored so we check the other eye
    // we are checking if the eye is closed
  }
  Future<bool> checkSmiling(String pic) async {
    Face _face = await fromImgToFace(pic);
    //print(_faces.smilingProbability!);
    return _face.smilingProbability! >= 0.9;
  }
  Future<bool> checkSmilingAndLeftEye(String pic) async {
    return await checkSmiling(pic) && await checkLeftEye(pic);
  }
  Future<bool> checkSmilingAndRightEye(String pic) async {
    return await checkSmiling(pic) && await checkRightEye(pic);
  }
  //Checking for head rotation (up/down/left/right)
  Future<bool> checkLookLeft(String pic) async {
    Face _face = await fromImgToFace(pic);
    return _face.headEulerAngleY! >= 30.0;
}
  Future<bool> checkLookRight(String pic) async {
    Face _face = await fromImgToFace(pic);
    return _face.headEulerAngleY! <= -30.0;
  }
  Future<bool> checkLookUp(String pic) async {
    Face _face = await fromImgToFace(pic);
    return _face.headEulerAngleX! >= 30.0;
  }
  Future<bool> checkLookDown(String pic) async {
    Face _face = await fromImgToFace(pic);
    print(_face.headEulerAngleX);
    return _face.headEulerAngleX! <= -20.0;
  }
  Future<Face> getFirstFaceFromImage(String pic) async{
    InputImage img = InputImage.fromFilePath(pic);
    List<Face> faceList= await detector.processImage(img);
    return faceList[0];
  }
  Future<img.Image> _cropFaceFromImage(img.Image image,String path) async{
    Face _face = await getFirstFaceFromImage(path);
    double x = _face.boundingBox.left - 10.0;
    double y = _face.boundingBox.top - 10.0;
    double w = _face.boundingBox.width + 10.0;
    double h = _face.boundingBox.height + 10.0;
    return img.copyCrop(image, x.round(), y.round(), w.round(), h.round());
  }
  Future<List> imageToFaceData(img.Image pic, Face face,String path) async{
    img.Image temp = await _cropFaceFromImage(pic, path);
    pic = img.copyResizeCropSquare(temp, 112);
    List imageAsList = _imageToByteListFloat32(pic);
    if (_interpreter == null){
      _delegate = GpuDelegateV2(
        options: GpuDelegateOptionsV2(
          isPrecisionLossAllowed: false,
          inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
          inferencePriority1: TfLiteGpuInferencePriority.minLatency,
          inferencePriority2: TfLiteGpuInferencePriority.auto,
          inferencePriority3: TfLiteGpuInferencePriority.auto,
        ),
      );
      _options?.addDelegate(_delegate!);
      _interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: _options);
    }
    if (face == null) throw Exception('Face is null');
    imageAsList = imageAsList.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    _interpreter?.run(imageAsList, output);
    output = output.reshape([192]);

    imageAsList = List.from(output);
    return imageAsList;
  }
  List _imageToByteListFloat32(img.Image image) { //turn image in usable data to pass to
    var convertedBytes = Float32List(1 * 112 * 112 * 3); // tensorflow interpreter
    var buffer = Float32List.view(convertedBytes.buffer); // with facenet model
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (img.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (img.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
  double _euclideanDistance(List? face1, List? face2) {
    if (face1 == null || face2 == null) throw Exception("Null argument");
    double sum = 0.0;
    for (int i = 0; i < face1.length; i++) {
      sum += pow((face1[i] - face2[i]), 2);
    }
    return sqrt(sum);
  }
  bool compareFaces(List face1,List face2){
    return _euclideanDistance(face1, face2) <= threshold;
  }
  Future<img.Image?> xFileToImage(XFile pic) async{
    final path = pic.path;
    final bytes = await File(path).readAsBytes();
    final img.Image? image = img.decodeImage(bytes);
    return image;
  }
}
