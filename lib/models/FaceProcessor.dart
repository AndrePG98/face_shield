import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:face_shield/models/CameraProcessor.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

class FaceProcessor{
  final double _threshold = 0.6; // threshold for face recognition (euclidean distance)
  final double _angleThreshold = 27.0;
  final double _eyesAndSmileThreshold = 0.9;
  late FaceDetector _detector;
  Delegate? _delegate;
  InterpreterOptions? _options;
  Interpreter? _interpreter;

  FaceProcessor(){
    _initiateInterpreter();
    _detector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate,
    enableClassification: true,enableTracking: true, enableContours: true));
  }

  Future<List<dynamic>> convertCameraImageToInputList(CameraImage cameraImage, CameraProcessor cameraProcessor) async {
    img.Image? returnImage;
    InputImage inputImage = InputImage.fromBytes(
      bytes: _concatenatePlanes(cameraImage.planes),
      inputImageData: InputImageData(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        imageRotation: cameraProcessor.cameraRotation ?? InputImageRotation.rotation0deg,
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

    final bytes = inputImage.bytes;
    if(bytes != null) {
      if(Platform.isAndroid){
        returnImage = img.decodeImage(bytes)!;
      } else if (Platform.isIOS){
        final rgbaBytes = Uint8List(cameraImage.width * cameraImage.height * 4);
        for (var i=0 , j=0; i < bytes.length; i+= 4 , j+= 3) {
          rgbaBytes[j] = bytes[i + 2];
          rgbaBytes[j + 1] = bytes[i + 1];
          rgbaBytes[j + 2] = bytes[i];
          rgbaBytes[j + 3] = 255;
        }
        returnImage = img.decodeImage(rgbaBytes);
      }
    }

    return [inputImage, returnImage];
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }


  Future<Face> _fromImgToFace(XFile pic) async{
    InputImage img = InputImage.fromFilePath(pic.path);
    List<Face> faces= await _detector.processImage(img);
    return faces[0];
  }
  Future<bool> checkLeftEye(XFile pic) async {
    Face face = await _fromImgToFace(pic);
    //print(_face.rightEyeOpenProbability);
    return !(face.rightEyeOpenProbability! >= _eyesAndSmileThreshold);
    // picture taken is mirrored so we check the other eye
    // we are checking if the eye is closed
  }
  Future<bool> checkRightEye(XFile pic) async {
    Face face = await _fromImgToFace(pic);
    //print(_face.leftEyeOpenProbability);
    return !(face.leftEyeOpenProbability! >= _eyesAndSmileThreshold);
    // picture taken is mirrored so we check the other eye
    // we are checking if the eye is closed
  }
  Future<bool> checkSmiling(XFile pic) async {
    Face face = await _fromImgToFace(pic);
    //print(_faces.smilingProbability!);
    return face.smilingProbability! >= _eyesAndSmileThreshold;
  }
  Future<bool> checkSmilingAndLeftEye(XFile pic) async {
    return await checkSmiling(pic) && await checkLeftEye(pic);
  }
  Future<bool> checkSmilingAndRightEye(XFile pic) async {
    return await checkSmiling(pic) && await checkRightEye(pic);
  }
  //Checking for head rotation (up/down/left/right)
  Future<bool> checkLookLeft(XFile pic) async {
    Face face = await _fromImgToFace(pic);
    return face.headEulerAngleY! >= _angleThreshold;
}
  Future<bool> checkLookRight(XFile pic) async {
    Face face = await _fromImgToFace(pic);
    return face.headEulerAngleY! <= -_angleThreshold;
  }
  Future<bool> checkLookUp(XFile pic) async {
    Face face = await _fromImgToFace(pic);
    return face.headEulerAngleX! >= _angleThreshold;
  }
  Future<bool> checkLookDown(XFile pic) async {
    Face face = await _fromImgToFace(pic);
    return face.headEulerAngleX! <= -_angleThreshold;
  }
  Future<Face> _getFirstFaceFromImage(XFile pic) async{
    InputImage img = InputImage.fromFilePath(pic.path);
    List<Face> faceList= await _detector.processImage(img);
    return faceList[0];
  }
  Future<bool>  isFaceDetected(XFile pic) async{
    InputImage img = InputImage.fromFilePath(pic.path);
    List<Face> faceList= await _detector.processImage(img);
    return faceList.isEmpty;
  }
  Future<img.Image> _cropFaceFromImage(XFile file) async{
    Face face = await _getFirstFaceFromImage(file);
    img.Image? image = await _xFileToImage(file);
    double x = face.boundingBox.left - 10.0;
    double y = face.boundingBox.top - 10.0;
    double w = face.boundingBox.width + 10.0;
    double h = face.boundingBox.height + 10.0;
    return img.copyCrop(image!, x: x.round(), y: y.round(), width: w.round(), height: h.round());
  }
  Future<List<double>> _imageToFaceData(XFile file) async{
    img.Image temp = await _cropFaceFromImage(file);
    img.Image pic = img.copyResizeCropSquare(temp, size: 112);
    List imageAsList = _imageToByteListFloat32(pic);
    if (_getFirstFaceFromImage(file) == null) throw Exception('NO FACE DETECTED IN PICTURE');
    imageAsList = imageAsList.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    _interpreter?.run(imageAsList, output);
    output = output.reshape([192]);

    List<double> finalList = List<double>.from(List.from(output));
    return finalList;
  }
  List _imageToByteListFloat32(img.Image image) { //turn image in usable data to pass to
    var convertedBytes = Float32List(1 * 112 * 112 * 3); // tensorflow interpreter
    var buffer = Float32List.view(convertedBytes.buffer); // with facenet model
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
  double _euclideanDistance(List? face1, List? face2) {
    double sum = 0.0;
    for (int i = 0; i < face1!.length; i++) {
      sum += pow((face1[i] - face2![i]), 2);
    }
    return sqrt(sum);
  }
  Future<bool> compareFaces(XFile input1,XFile input2) async{
    List<dynamic> face1 = await _imageToFaceData(input1);
    List<dynamic> face2 = await _imageToFaceData(input1);
    return _euclideanDistance(face1, face2) <= _threshold;
  }
  Future<img.Image?> _xFileToImage(XFile pic) async{
    final path = pic.path;
    final bytes = await File(path).readAsBytes();
    final img.Image? image = img.decodeImage(bytes);
    return image;
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
  void insertUserInDataBase(String username,String password,List<double> faceData){
    // DBhelper.insertUser(username,password,faceData);
  }
}
