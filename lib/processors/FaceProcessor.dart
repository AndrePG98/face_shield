import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:face_shield/services/api.dart';

class FaceProcessor{
  final double _threshold = 0.6; // threshold for face recognition (euclidean distance)
  final double _angleThreshold = 15.0;
  final double _eyesAndSmileThreshold = 0.9;
  late FaceDetector _detector;
  Delegate? _delegate;
  InterpreterOptions? _options;
  Interpreter? _interpreter;
  late InputImageRotation? cameraRotation;
  Map<FaceLandmarkType, FaceLandmark?> _previousFrameLandmarks = Map();
  late CameraImage _tempImage; //later bull

  FaceProcessor(){
    _initiateInterpreter();
    _detector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate,
    enableClassification: true,enableTracking: true, enableContours: true, enableLandmarks: true));
  }
  Future<Face> _fromImgToFace(CameraImage cameraImage) async{
    List<dynamic> lists = await convertCameraImageToInputList(cameraImage);
    InputImage inputImage = lists[0];
    List<Face> faces= await _detector.processImage(inputImage);
    return faces[0];
  }

  Future<List<Face>> detect(CameraImage cameraImage) async {
    List<dynamic> inputs = await convertCameraImageToInputList(cameraImage);
    return await _detector.processImage(inputs[0]);
  }

  Future<bool> checkLeftEye(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    //print(_face.rightEyeOpenProbability);
    return !(face.rightEyeOpenProbability! >= _eyesAndSmileThreshold);
    // picture taken is mirrored so we check the other eye
    // we are checking if the eye is closed
  }
  Future<bool> checkRightEye(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    //print(_face.leftEyeOpenProbability);
    return !(face.leftEyeOpenProbability! >= _eyesAndSmileThreshold);
    // picture taken is mirrored so we check the other eye
    // we are checking if the eye is closed
  }

  Future<bool> checkEyeBlink(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    double leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0.0;
    double rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0.0;

    // Define a threshold for eye openness probability to consider an eye blink
    double eyeOpenThreshold = 0.45;

    // Check if both eyes are closed (below the threshold)
    bool isBlinking = leftEyeOpenProbability < eyeOpenThreshold &&
        rightEyeOpenProbability < eyeOpenThreshold;

    return isBlinking;
  }

  Future<bool> checkFaceMovement(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    double faceMovementThreshold = 4.0; // Define a threshold for face movement
    if(_previousFrameLandmarks.isEmpty){
      _previousFrameLandmarks = face.landmarks;
      return false;
    }
   Map<FaceLandmarkType, FaceLandmark?> landmarks = face.landmarks;
    double totalDistance = 0.0;
    for (var element in landmarks.values) {
      totalDistance += element!.position.distanceTo(_previousFrameLandmarks[element.type]!.position);
    }

    // Calculate the average distance
    double averageDistance = totalDistance / landmarks.length;

    // Check if the average distance exceeds the threshold
    bool isMoving = averageDistance > faceMovementThreshold;
    _previousFrameLandmarks = face.landmarks;
    return isMoving;
  }

  Future<bool> checkSmiling(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    //print(_faces.smilingProbability!);
    return face.smilingProbability! >= _eyesAndSmileThreshold;
  }
  Future<bool> checkSmilingAndLeftEye(CameraImage cameraImage) async {
    return await checkSmiling(cameraImage) && await checkLeftEye(cameraImage);
  }
  Future<bool> checkSmilingAndRightEye(CameraImage cameraImage) async {
    return await checkSmiling(cameraImage) && await checkRightEye(cameraImage);
  }
  //Checking for head rotation (up/down/left/right)
  Future<bool> checkLookLeft(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    return face.headEulerAngleY! >= _angleThreshold;
}
  Future<bool> checkLookRight(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    return face.headEulerAngleY! <= -_angleThreshold;
  }
  Future<bool> checkLookUp(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    return face.headEulerAngleX! >= _angleThreshold;
  }
  Future<bool> checkLookDown(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    return face.headEulerAngleX! <= -_angleThreshold;
  }
  Future<Face> getFirstFaceFromImage(CameraImage cameraImage) async{
    List<dynamic> lists = await convertCameraImageToInputList(cameraImage);
    InputImage inputImage = lists[0];
    List<Face> faceList= await _detector.processImage(inputImage);
    return faceList[0];
  }
  Future<bool>  isFaceDetected(CameraImage cameraImage) async{
    List<dynamic> lists = await convertCameraImageToInputList(cameraImage);
    InputImage inputImage = lists[0];
    List<Face> faceList= await _detector.processImage(inputImage);
    return faceList.isNotEmpty;
  }
  Future<img.Image> cropFaceFromImage(CameraImage cameraImage) async{
    List<dynamic> inputs = await convertCameraImageToInputList(cameraImage);
    Face face = await getFirstFaceFromImage(inputs[0]);
    img.Image? image = inputs[1];
    double x = face.boundingBox.left - 10.0;
    double y = face.boundingBox.top - 10.0;
    double w = face.boundingBox.width + 10.0;
    double h = face.boundingBox.height + 10.0;
    return img.copyCrop(image!, x: x.round(), y: y.round(), width: w.round(), height: h.round());
  }
  Future<List<double>> imageToFaceData(CameraImage cameraImage) async{
    img.Image temp = await cropFaceFromImage(cameraImage);
    img.Image pic = img.copyResizeCropSquare(temp, size: 112);
    List imageAsList = _imageToByteListFloat32(pic);
    if (getFirstFaceFromImage(cameraImage) == null) throw Exception('NO FACE DETECTED IN PICTURE');
    imageAsList = imageAsList.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    _interpreter?.run(imageAsList, output);
    output = output.reshape([192]);

    List<double> finalList = List<double>.from(List.from(output));
    return finalList;
  }
  List _imageToByteListFloat32(img.Image image) { //turn image in usable data to pass to
    var convertedBytes = Float32List(1 * 112 * 112 * 3); // tensorflow interpreter
    var buffer = Float32List.view(convertedBytes.buffer); // with faceNet model
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - 128) / 128;
        buffer[pixelIndex++] = (pixel.g - 128) / 128;
        buffer[pixelIndex++] = (pixel.b - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
  double euclideanDistance(List? face1, List? face2) {
    double sum = 0.0;
    for (int i = 0; i < face1!.length; i++) {
      sum += pow((face1[i] - face2![i]), 2);
    }
    return sqrt(sum);
  }

  Future<bool> compareFaces(CameraImage cameraImage,List<double> prediction) async{
    List<dynamic> inputFace = await imageToFaceData(cameraImage);
    return euclideanDistance(inputFace, prediction) <= _threshold;
  }

  Future<bool> compareFacesWithoutCameraImage(List<double> inputFace,List<double> prediction) async{
    return euclideanDistance(inputFace, prediction) <= _threshold;
  }


  void _initiateInterpreter() async{
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

Future<InputImage> _fromCameraImageToInputImage(CameraImage cameraImage) async{
    InputImage inputImage = InputImage.fromBytes(
      bytes: _concatenatePlanes(cameraImage.planes),
      inputImageData: InputImageData(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        imageRotation: cameraRotation ?? InputImageRotation.rotation0deg,
        inputImageFormat: InputImageFormatValue.fromRawValue(cameraImage.format.raw) ??  InputImageFormat.yuv_420_888,
        planeData: cameraImage.planes.map(
              (Plane plane) {
            return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            );
          },
        ).toList(),
      ),
    );
    return inputImage;
  }

  Future<img.Image?> fromCameraImageToImage(CameraImage cameraImage, InputImage inputImage) async{
    final bytes = inputImage.bytes;
    if(bytes != null) {
      if(Platform.isAndroid){
        return img.decodeImage(bytes);
      } else if (Platform.isIOS){
        final rgbaBytes = Uint8List(cameraImage.width * cameraImage.height * 4);
        for (var i=0 , j=0; i < bytes.length; i+= 4 , j+= 3) {
          rgbaBytes[j] = bytes[i + 2];
          rgbaBytes[j + 1] = bytes[i + 1];
          rgbaBytes[j + 2] = bytes[i];
          rgbaBytes[j + 3] = 255;
        }
        return img.decodeImage(rgbaBytes);
      }
    }
    return img.decodeImage(0 as Uint8List);
  }

  Future<Uint8List> fromCameraImageToBytes(CameraImage cameraImage) async{
    final rgbaBytes = Uint8List(cameraImage.width * cameraImage.height * 4);
    InputImage inputImage = await _fromCameraImageToInputImage(cameraImage);
    final bytes = inputImage.bytes;
    if(bytes != null) {
      for (var i=0 , j=0; i < bytes.length; i+= 4 , j+= 3) {
        rgbaBytes[j] = bytes[i + 2];
        rgbaBytes[j + 1] = bytes[i + 1];
        rgbaBytes[j + 2] = bytes[i];
        rgbaBytes[j + 3] = 255;
      }
    }
    return rgbaBytes;
  }

  Future<Uint8List> getDisplayImg(CameraImage cameraImage) async {
    img.Image? result = await fromCameraImageToImage(cameraImage);
    return img.encodePng(result!);
  }

  Future<List<dynamic>> convertCameraImageToInputList(CameraImage cameraImage)  async{
    InputImage inputImage = await _fromCameraImageToInputImage(cameraImage);
    img.Image? returnImage = await fromCameraImageToImage(cameraImage, inputImage);
    return [inputImage, returnImage];
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }



  Future<Object> findBestMatchingUser(List<double> currentUserFaceData) async {
    final allUsers = await fetchAllUsers();

    double bestDistance = 1.0;
    Map<String, dynamic>? bestMatchingUser;

    for (var user in allUsers) {
      final faceData = List<double>.from(user['faceData']);
      double distance = euclideanDistance(currentUserFaceData, faceData);

      if (distance < bestDistance) {
        bestDistance = distance;
        bestMatchingUser = user;
      }
    }

    if (bestDistance > _threshold){
      return 'No matching user';
    }
    else{
      if(bestMatchingUser == null){
        return 'No matching user';
      }
      else{
        return bestMatchingUser;
      }
    }
  }
}

