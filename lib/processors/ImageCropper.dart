import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class ImageCropper {

  Future<ui.Image?> cropImage(String imagePath) async {
    final image = InputImage.fromFilePath(imagePath);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true,
        enableTracking: true,
        enableContours: true,
        enableLandmarks: true,
      ),
    );
    final faces = await faceDetector.processImage(image);

    if (faces.isEmpty) {
      // No faces detected
      return null;
    }

    final detectedFace = faces.first;
    final inputImageData = await _loadImage(imagePath);
    final imageWidth = inputImageData.width.toDouble();
    final imageHeight = inputImageData.height.toDouble();

    // Calculate the bounding box of the detected face
    final boundingBox = detectedFace.boundingBox;
    final left = (boundingBox.left * imageWidth).toInt();
    final top = (boundingBox.top * imageHeight).toInt();
    final width = (boundingBox.width * imageWidth).toInt();
    final height = (boundingBox.height * imageHeight).toInt();

    // Create a cropped image using the calculated bounding box
    final croppedImage = await _cropImage(inputImageData, left, top, width, height);

    return croppedImage;
  }

  Future<ui.Image> _cropImage(ui.Image inputImage, int left, int top, int width, int height) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final cropRect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    final srcRect = Rect.fromLTWH(left.toDouble(), top.toDouble(), width.toDouble(), height.toDouble());

    canvas.drawImageRect(inputImage, srcRect, cropRect, Paint());

    final croppedImage = await pictureRecorder.endRecording().toImage(width, height);
    return croppedImage;
  }

  Future<ui.Image> _loadImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}
