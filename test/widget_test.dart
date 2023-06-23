import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('Counter increments count to 5', (WidgetTester tester) async {
    int a =6;
    int b =5;
    int soma = a+b;

    expect(soma, 11);
  });

}