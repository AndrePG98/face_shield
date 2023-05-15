import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class ProofOfLifeAlert{
  final String prompt;
  bool isVisible;

  ProofOfLifeAlert({
    required this.prompt,
    required this.isVisible
  });
}