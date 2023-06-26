import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class FeatureExtraction {
  tfl.Interpreter? _interpreter;
  late int _inputSize;
  late int _outputSize;
  late int _numChannels;

  Future<void> loadModel(String modelPath) async {
    final modelFile = await File(modelPath).readAsBytes();
    final modelBuffer = modelFile.buffer;
    final modelData = modelBuffer.asUint8List();
    _interpreter = await tfl.Interpreter.fromBuffer(modelData);
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    _inputSize = inputShape[1];
    _outputSize = outputShape[1];
    _numChannels = inputShape[3];
  }

  Future<Uint8List> extractFacialInformationFromCroppedImage(ui.Image croppedImage) async {
    final inputTensorData = await _processCroppedImage(croppedImage);

    // Run the inference
    final outputTensor = Float32List(_outputSize);
    final inputs = [inputTensorData];
    final outputs = {0: outputTensor};

    _interpreter!.runForMultipleInputs(inputs, outputs);

    return outputTensor.buffer.asUint8List();
  }

  Future<Uint8List> _processCroppedImage(ui.Image croppedImage) async {
    final resizedImage = img.copyResize(
      img.Image.fromBytes(croppedImage.width, croppedImage.height, await _convertImageToByteList(croppedImage)),
      width: _inputSize,
      height: _inputSize,
    );


    final inputTensor = Float32List(_inputSize * _inputSize * _numChannels);
    for (var i = 0; i < _inputSize; i++) {
      for (var j = 0; j < _inputSize; j++) {
        final pixel = resizedImage.getPixel(j, i);
        inputTensor[i * _inputSize * _numChannels + j * _numChannels + 0] = img.getRed(pixel) / 255;
        inputTensor[i * _inputSize * _numChannels + j * _numChannels + 1] = img.getGreen(pixel) / 255;
        inputTensor[i * _inputSize * _numChannels + j * _numChannels + 2] = img.getBlue(pixel) / 255;
      }
    }

    return inputTensor.buffer.asUint8List();
  }

  Future<List<int>> _convertImageToByteList(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    return bytes;
  }

  double calculateEuclideanDistance(Uint8List tensorData1, Uint8List tensorData2) {
    assert(tensorData1.length == tensorData2.length);

    double squaredSum = 0;
    for (int i = 0; i < tensorData1.length; i++) {
      final diff = tensorData1[i] - tensorData2[i];
      squaredSum += diff * diff;
    }

    return sqrt(squaredSum);
  }

  bool compareFacialInformation(Uint8List tensorData1, Uint8List tensorData2) {
    final distance = calculateEuclideanDistance(tensorData1, tensorData2);
    // Adjust the threshold value according to your specific model and requirements
    return distance < 10.0; // Example threshold: 10.0
  }
}
