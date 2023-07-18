import 'package:face_shield/routes/ListUsersPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Visibility of elements in ListUsersPage', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ListUsersPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
