import 'package:face_shield/routes/UserDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('User Detail Page - Element Visibility', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: UserDetailPage(
      id: 'test_id',
      email: 'test@example.com',
      faceData: [1.0, 2.0, 3.0],
    )));

    expect(find.text('User Detail'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('User Detail Page - Edit Button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: UserDetailPage(
      id: 'test_id',
      email: 'test@example.com',
      faceData: [1.0, 2.0, 3.0],
    )));

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit user'), findsOneWidget);

    final emailFormFieldFinder = find.widgetWithText(TextFormField, 'Email');
    expect(emailFormFieldFinder, findsOneWidget);

    await tester.enterText(emailFormFieldFinder, 'newemail@example.com');
    await tester.pump();

    final deleteButton = find.widgetWithText(ElevatedButton, 'Delete');
    expect(deleteButton, findsOneWidget);

    final editButton = find.widgetWithText(ElevatedButton, 'Edit');
    expect(editButton, findsOneWidget);

    final cancelButton = find.widgetWithText(TextButton, 'Cancel');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
  });

  testWidgets('User Detail Page - Delete Button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: UserDetailPage(
      id: 'test_id',
      email: 'test@example.com',
      faceData: [1.0, 2.0, 3.0],
    )));

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Do you want to delete this user?'), findsOneWidget);

    final deleteButton = find.widgetWithText(ElevatedButton, 'Delete');
    expect(deleteButton, findsOneWidget);

    final editButton = find.widgetWithText(ElevatedButton, 'Edit');
    expect(editButton, findsOneWidget);

    final cancelButton = find.widgetWithText(TextButton, 'Cancel');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
  });

  testWidgets('User Detail Page - Delete Confirmation', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: UserDetailPage(
      id: 'test_id',
      email: 'test@example.com',
      faceData: [1.0, 2.0, 3.0],
    )));

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Do you want to delete this user?'), findsOneWidget);

    final deleteButton = find.widgetWithText(ElevatedButton, 'Delete');
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
  });
}

