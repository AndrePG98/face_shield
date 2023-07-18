import 'package:face_shield/components/logo.dart';
import 'package:face_shield/routes/ListUsersPage.dart';
import 'package:face_shield/routes/LogInDetectionRoute.dart';
import 'package:face_shield/routes/SignUpPage.dart';
import 'package:face_shield/routes/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home Page Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget( MaterialApp(home: HomePage(), routes: <String, WidgetBuilder> {
      '/login' : (BuildContext context) => LogInDetectionWidget(),
      '/signup' : (BuildContext context) => const SignUpPage(),
      '/listusers': (BuildContext context) => const ListUsersPage()
    },));

    expect(find.byType(Logo), findsOneWidget);

    final Finder loginButton = find.widgetWithText(OutlinedButton, 'Log in');
    expect(loginButton, findsOneWidget);

    final Finder signUpButton = find.widgetWithText(OutlinedButton, 'Sign up');
    expect(signUpButton, findsOneWidget);

    final Finder listUsersButton = find.widgetWithText(OutlinedButton, 'List users');
    expect(listUsersButton, findsOneWidget);

    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpPage), findsOneWidget);
  });

}