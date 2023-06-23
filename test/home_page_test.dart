import 'package:face_shield/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('Home Page Test', (WidgetTester tester) async {
    await tester.pumpWidget(MainApp());
    final Finder loginButton = find.widgetWithText(OutlinedButton, 'Log in');
    expect(loginButton, findsOneWidget);

    final Finder signUpButton = find.widgetWithText(OutlinedButton, 'Sign up');
    expect(signUpButton, findsOneWidget);

    final Finder listUsersButton = find.widgetWithText(OutlinedButton, 'List users');
    expect(listUsersButton, findsOneWidget);

    // expect('Sign Up', findsOneWidget);
    //expect('List Users', findsOneWidget);

  });

}