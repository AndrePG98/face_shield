import 'dart:async';
import 'package:flutter/material.dart';


class ConditionChecker {
  final StreamController<List<bool>> _streamController = StreamController<List<bool>>();
  Stream<List<bool>> get conditionStream => _streamController.stream;

  void checkConditions(List<bool> boolList) {
    _streamController.add(boolList);
  }

  void dispose() {
    _streamController.close();
  }
}