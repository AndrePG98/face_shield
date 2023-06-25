import 'package:face_shield/routes/SignUpPage.dart';
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
    final passwordField = find.byKey(const Key('passwordField'));
    final repeatPasswordField = find.byKey(const Key('repeatPasswordField'));
    final createAccountButton = find.widgetWithText(ElevatedButton, 'Create Account');




    await tester.enterText(emailField, 'google@gmail.com');
    expect(find.text('Invalid email'), findsNothing);

    await tester.enterText(passwordField, 'password12345678');
    expect(find.text('Password must match'), findsOneWidget);

    await tester.enterText(repeatPasswordField, 'password12345678');
    expect(find.text('Password must match'), findsOneWidget);

    expect(createAccountButton, findsOneWidget);

    final appBar = find.byType(AppBar);
    expect(appBar, findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Toggle password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SignUpPage()));

    await tester.tap(find.byKey(const Key('passwordField')));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
    expect(find.byType(TextField).last, findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, true);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsNothing);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.byType(TextField).last, findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, false);
  });
}
