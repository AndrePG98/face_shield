import 'package:face_shield/routes/SignUpPage.dart';
import 'package:face_shield/routes/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAPI extends Mock {}

void main() {
  late SignUpPage signUpPage;
  late MockAPI mockAPI;

  setUp(() {
    mockAPI = MockAPI();
    signUpPage = SignUpPage();
  });

  testWidgets('Sign up page Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: signUpPage));

    final emailField= find.byKey(const Key('emailField'));
    await tester.enterText(emailField, 'google@gmail.com');
    expect(find.text('Invalid email'), findsNothing);
  });
}
