import 'package:face_shield/routes/contactInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';



void main() {
  late ContactInfoPage contactInfoPage;

  setUp(() {
    contactInfoPage = ContactInfoPage();
  });

  testWidgets('ContactInfoPage - AppBar Title Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: contactInfoPage));

    expect(find.text('Contact Info'), findsOneWidget);
  });

  testWidgets('ContactInfoPage - Contact Information Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: contactInfoPage));

    expect(find.text('Contact Information'), findsOneWidget);
    expect(find.byIcon(Icons.phone), findsNWidgets(2));
    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.text('+351 931 112 321'), findsOneWidget);
    expect(find.text('+351 921 109 345'), findsOneWidget);
    expect(find.text('support@faceshield.com'), findsOneWidget);
  });
}
