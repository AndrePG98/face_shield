import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:face_shield/services/api.dart';

class FaceProcessor {
  final double _threshold =
      0.8; // threshold for face recognition (euclidean distance)
  final double _angleThreshold = 20;
  final double _eyesAndSmileThreshold = 0.8;
  late FaceDetector _detector;
  Delegate? _delegate;
  InterpreterOptions? _options;
  Interpreter? _interpreter;
  late InputImageRotation? cameraRotation;
  Face? previousFace;
  Map<FaceLandmarkType, FaceLandmark?> _previousFrameLandmarks = Map();

  FaceProcessor() {
    _initiateInterpreter();
    _detector = FaceDetector(
        options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.accurate,
            enableClassification: true,
            enableTracking: true,
            enableContours: true,
            enableLandmarks: true));
  }
  Future<Face> _fromImgToFace(CameraImage cameraImage) async {
    InputImage inputImage = await _fromCameraImageToInputImage(cameraImage);
    List<Face> faces = await _detector.processImage(inputImage);
    return faces[0];
  }

  Future<List<Face>> detect(CameraImage cameraImage) async {
    InputImage inputImage = await _fromCameraImageToInputImage(cameraImage);
    return await _detector.processImage(inputImage);
  }

  Future<bool> checkLiveness(CameraImage cameraImage) async {
    if (previousFace == null) {
      previousFace = await _fromImgToFace(cameraImage);
      return false;
    }
    Face face = await _fromImgToFace(cameraImage);
    bool isFaceMoving = await checkFaceMovement(face);
    bool isEyeBlinking = await checkEyeBlink(face);

    if (isFaceMoving && isEyeBlinking) {
      return true; // If the face is moving and the user is blinking, consider it as a liveness indication
    }

    // If neither face movement nor blinking is detected, perform additional checks or return a default value
    // You can implement other checks here, such as smiling detection, head rotation analysis, or a combination of different checks

    return false; // Default return value if no conclusive result is obtained
  }

  Future<bool> checkEyeBlink(Face face) async {
    double leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0.0;
    double rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0.0;
    double previousLeftEyeOpenProbability =
        previousFace?.leftEyeOpenProbability ?? 0.0;
    double previousRightEyeOpenProbability =
        previousFace?.rightEyeOpenProbability ?? 0.0;

    bool previousEyesOpen = (previousLeftEyeOpenProbability >= 0.5 &&
        previousRightEyeOpenProbability >= 0.5);

    // Define a threshold for eye openness probability to consider an eye blink
    double eyeOpenThreshold = 0.15;

    // Check if the eyes transitioned from open to closed or closed to open, considering the threshold
    bool isBlinking = (previousEyesOpen &&
            leftEyeOpenProbability < eyeOpenThreshold &&
            rightEyeOpenProbability < eyeOpenThreshold) ||
        (!previousEyesOpen &&
            (leftEyeOpenProbability >= eyeOpenThreshold ||
                rightEyeOpenProbability >= eyeOpenThreshold));

    return isBlinking;
  }

  Future<bool> checkEyeBlinkWithCameraImage(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    double leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0.0;
    double rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0.0;

    // Define a threshold for eye openness probability to consider an eye blink

    // Check if both eyes are closed (below the threshold)
    bool isBlinking = leftEyeOpenProbability < _eyesAndSmileThreshold &&
        rightEyeOpenProbability < _eyesAndSmileThreshold;

    return isBlinking;
  }

  Future<bool> checkFaceMovement(Face face) async {
    double faceMovementThreshold = 4; // Define a threshold for face movement

    if (_previousFrameLandmarks.isEmpty) {
      _previousFrameLandmarks = face.landmarks;
      return false;
    }

    Map<FaceLandmarkType, FaceLandmark?> landmarks = face.landmarks;
    double totalDistance = 0.0;
    int numValidLandmarks = 0;

    for (var entry in landmarks.entries) {
      FaceLandmarkType landmarkType = entry.key;
      FaceLandmark? currentLandmark = entry.value;
      FaceLandmark? previousLandmark = _previousFrameLandmarks[landmarkType];

      if (currentLandmark != null && previousLandmark != null) {
        double distance =
            currentLandmark.position.distanceTo(previousLandmark.position);
        totalDistance += distance;
        numValidLandmarks++;
      }
    }

    double averageDistance = totalDistance / numValidLandmarks;
    _previousFrameLandmarks =
        face.landmarks; // Update the previous frame landmarks

    return averageDistance >= faceMovementThreshold;
  }

  Future<bool> checkSmiling(CameraImage cameraImage) async {
    Face face = await _fromImgToFace(cameraImage);
    return face.smilingProbability! >= _eyesAndSmileThreshold;
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

  Future<Face> getFirstFaceFromImage(InputImage inputImage) async {
    List<Face> faceList = await _detector.processImage(inputImage);
    return faceList[0];
  }

  Future<img.Image> cropFaceFromImage(
      InputImage inputImage, img.Image image) async {
    Face face = await getFirstFaceFromImage(inputImage);
    double x = face.boundingBox.left - 10;
    double y = face.boundingBox.top - 10;
    double w = face.boundingBox.width + 10;
    double h = face.boundingBox.height + 10;
    return img.copyCrop(image, x.round(), y.round(), w.round(), h.round());
  }

  List _imageToByteListFloat32(img.Image image) {
    //turn image in usable data to pass to
    var convertedBytes =
        Float32List(1 * 112 * 112 * 3); // tensorflow interpreter
    var buffer = Float32List.view(convertedBytes.buffer); // with faceNet model
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

  double euclideanDistance(List? face1, List? face2) {
    double sum = 0.0;
    for (int i = 0; i < face1!.length; i++) {
      sum += pow((face1[i] - face2![i]), 2);
    }
    return sqrt(sum);
  }

  void _initiateInterpreter() async {
    _delegate = GpuDelegateV2(
      options: GpuDelegateOptionsV2(
        isPrecisionLossAllowed: false,
        inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
        inferencePriority1: TfLiteGpuInferencePriority.maxPrecision,
        inferencePriority2: TfLiteGpuInferencePriority.auto,
        inferencePriority3: TfLiteGpuInferencePriority.auto,
      ),
    );
    _options?.addDelegate(_delegate!);
    _interpreter =
        await Interpreter.fromAsset('mobilefacenet.tflite', options: _options);
  }

  Future<InputImage> _fromCameraImageToInputImage(
      CameraImage cameraImage) async {
    //helper function for convertCameraImageToInputList
    InputImage inputImage = InputImage.fromBytes(
      bytes: _concatenatePlanes(cameraImage.planes),
      inputImageData: InputImageData(
        size: ui.Size(
            cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        imageRotation: cameraRotation ?? InputImageRotation.rotation0deg,
        inputImageFormat:
            InputImageFormatValue.fromRawValue(cameraImage.format.raw) ??
                InputImageFormat.yuv_420_888,
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

  Future<List<dynamic>> convertCameraImageToInputList(
      CameraImage cameraImage) async {
    InputImage inputImage = await _fromCameraImageToInputImage(cameraImage);
    img.Image? returnImage = _convertToImage(cameraImage);
    return [inputImage, returnImage];
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    // helper function for _fromCameraImageToInputImage
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future<Object> findBestMatchingUser(List<double> currentUserFaceData) async {
    final allUsers = await fetchAllUsers();
    if (allUsers.isNotEmpty) {
      double bestDistance = double.infinity;
      Map<String, dynamic>? bestMatchingUser;
      for (var user in allUsers) {
        final faceData = List<double>.from(user['faceData']);
        double distance = euclideanDistance(currentUserFaceData, faceData);
        if (distance < bestDistance) {
          bestDistance = distance;
          bestMatchingUser = user;
        }
      }
      if (bestMatchingUser == null) {
        return false;
      }
      if (bestDistance >= 0.8) {
        return false;
      }
      return bestMatchingUser;
    }
    return false;
  }

  img.Image _convertYUV420(CameraImage cameraImage) {
    //helper function for _convertToImage
    int width = cameraImage.width;
    int height = cameraImage.height;
    var image = img.Image(width, height);
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = cameraImage.planes[1].bytesPerRow;
    final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex = uvPixelStride! * (x / 2).floor() +
            uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = cameraImage.planes[0].bytes[index];
        final up = cameraImage.planes[1].bytes[uvIndex];
        final vp = cameraImage.planes[2].bytes[uvIndex];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        image.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }

    return image;
  }

  img.Image _convertBGRA8888(CameraImage cameraImage) {
    //helper function for _convertToImage
    return img.Image.fromBytes(
      cameraImage.width,
      cameraImage.height,
      cameraImage.planes[0].bytes,
      format: img.Format.bgra,
    );
  }

  img.Image _convertToImage(CameraImage cameraImage) {
    //converting CameraImage object to Image
    //for cropping and usage in _imageToByteListFloat32
    //helper function for convertCameraImageToInputList
    try {
      print('image.format.group=>${cameraImage.format.group}');
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888(cameraImage);
      }
      throw Exception('Image format not supported');
    } catch (e) {
      print("ERROR:$e");
    }
    throw Exception('Image format not supported');
  }

  double cosineSim(List<dynamic> list1, List<dynamic> list2) {
    double dot = 0.0;
    double x = 0.0;
    double y = 0.0;
    for (int i = 0; i < list1!.length; i++) {
      dot += list1[i] * list2[i];
      x += pow(list1[i], 2);
      y += pow(list2[i], 2);
    }
    double result = dot / (sqrt(x) * sqrt(y));
    return result;
  }

  Future<img.Image?> _xFileToImage(XFile pic) async {
    final path = pic.path;
    final bytes = await File(path).readAsBytes();
    final img.Image? image = img.decodeImage(bytes);
    return image;
  }

  Future<List<double>> imageToFaceData(String filePath) async {
    XFile file = XFile(filePath);
    img.Image temp = await _cropFaceFromImage(file);
    img.Image pic = img.copyResizeCropSquare(temp, 112);
    List imageAsList = _imageToByteListFloat32(pic);
    imageAsList = imageAsList.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    _interpreter?.run(imageAsList, output);
    output = output.reshape([192]);

    List<double> finalList = List<double>.from(List.from(output));
    return finalList;
  }

  Future<img.Image> _cropFaceFromImage(XFile file) async {
    Face face = await _getFirstFaceFromImage(file);
    img.Image? image = await _xFileToImage(file!);
    double x = face.boundingBox.left - 10.0;
    double y = face.boundingBox.top - 10.0;
    double w = face.boundingBox.width + 10.0;
    double h = face.boundingBox.height + 10.0;
    return img.copyCrop(image!, x.round(), y.round(), w.round(), h.round());
  }

  Future<Face> _getFirstFaceFromImage(XFile pic) async {
    InputImage img = InputImage.fromFilePath(pic.path);
    List<Face> faceList = await _detector.processImage(img);
    return faceList[0];
  }

  Future<Object> findBestMatchingUserCosine(
      List<double> currentUserFaceData) async {
    final allUsers = await fetchAllUsers();
    if (allUsers.isNotEmpty) {
      double bestDistance = 0;
      Map<String, dynamic>? bestMatchingUser;
      for (var user in allUsers) {
        final faceData = List<double>.from(user['faceData']);
        double distance = cosineSim(currentUserFaceData, faceData);
        if (distance > bestDistance) {
          bestDistance = distance;
          bestMatchingUser = user;
        }
      }
      if (bestMatchingUser == null) {
        return false;
      }
      if (bestDistance <= _threshold) {
        return false;
      }
      return bestMatchingUser;
    }
    return false;
  }
}
