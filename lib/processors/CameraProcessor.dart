import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';


class CameraProcessor{
  late CameraController _controller;
  CameraController get controller => _controller;

  InputImageRotation? _cameraRotation;
  InputImageRotation? get cameraRotation => _cameraRotation;

  String? _imagePath;
  String? get imagePath => _imagePath;

  bool isInitialized = false;

  Future<void> initialize() async {
    CameraDescription cameraDescription = await _getCameraDescription();
    await _setupCameraController(description: cameraDescription);
    _cameraRotation = rotationIntToImageRotation(cameraDescription.sensorOrientation);
    _controller.setFlashMode(FlashMode.auto);
    isInitialized = true;
  }

  Future<CameraDescription> _getCameraDescription() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere((CameraDescription camera) =>
    camera.lensDirection == CameraLensDirection.front);
  }

  Future _setupCameraController({
    required CameraDescription description,
  }) async {
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller.initialize();
  }

  Future<XFile?> takePicture() async {
    await _controller.stopImageStream();
    XFile? file = await _controller.takePicture();
    _imagePath = file.path;
    return file;
  }

  Size getImageSize() {
    assert(
    _controller.value.previewSize != null,
    'Preview size is null',
    );
    return Size(
      _controller.value.previewSize!.height,
      _controller.value.previewSize!.width,
    );
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  dispose() async {
    await _controller.dispose();
    isInitialized = false;
  }
}