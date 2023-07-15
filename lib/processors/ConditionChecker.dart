import 'dart:async';

class ConditionChecker {
  final StreamController<List<bool>> _streamController =
      StreamController<List<bool>>.broadcast();
  Stream<List<bool>> get conditionStream => _streamController.stream;

  void addConditions(List<bool> boolList) {
    _streamController.add(boolList);
  }

  void resetConditions() {
    _streamController.add([]);
  }

  void dispose() {
    _streamController.close();
  }
}
