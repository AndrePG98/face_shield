import 'package:face_shield/routes/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';



class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late SettingsPage settingsPage;

  setUp(() {
    settingsPage = SettingsPage(email: 'test@example.com');
  });

  testWidgets('Settings Page - Item Count Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: settingsPage));

    expect(find.byType(ListTile), findsNWidgets(3));
  });

  testWidgets('Settings Page - Item Titles Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: settingsPage));

    expect(find.text('Edit Email'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Settings Page - Item Icons Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: settingsPage));

    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('Settings Page - Edit Item Click Test', (WidgetTester tester) async {
    final mockContext = MockBuildContext();
    await tester.pumpWidget(MaterialApp(home: settingsPage));

    await tester.tap(find.text('Edit Email'));
    await tester.pumpAndSettle();

  });

  testWidgets('Settings Page - Delete Item Click Test', (WidgetTester tester) async {
    final mockContext = MockBuildContext();
    await tester.pumpWidget(MaterialApp(home: settingsPage));

    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

  });

  testWidgets('Settings Page - Logout Item Click Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: settingsPage));

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
