import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/routes/userFeed.dart';


void main() {
  late UserFeed userFeed;

  setUp(() {
    userFeed = UserFeed();
  });

  testWidgets('UserFeed - AppBar Title Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: userFeed));

    expect(find.text('User'), findsOneWidget);
  });

  testWidgets('UserFeed - Welcome Text Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: userFeed));

    expect(find.text('Welcome to FaceShield'), findsOneWidget);
  });

  testWidgets('UserFeed - Card Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: userFeed));

    expect(find.byType(Card), findsNWidgets(3));
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('user_email@example.com'), findsOneWidget);
  });

  testWidgets('UserFeed - GestureDetector Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: userFeed));

    expect(find.byType(GestureDetector), findsNWidgets(5));
    expect(find.byType(Card), findsNWidgets(3));
    expect(find.byType(Image), findsNWidgets(2));

    // Validate image loading
    final networkImages = tester.widgetList<Image>(find.byType(NetworkImage));

    for (final imageWidget in networkImages) {
      final imageProvider = imageWidget.image as NetworkImage;
      final imageKey = imageProvider.url;
      expect(imageKey, isNotEmpty);

      await tester.runAsync(() async {
        final imageStream = imageProvider.resolve(ImageConfiguration.empty);
        final listener = ImageStreamListener(
              (ImageInfo info, bool synchronousCall) {},
          onError: (dynamic exception, StackTrace? stackTrace) {
            fail('Failed to load image: $exception');
          },
        );
        imageStream.addListener(listener);
        await tester.pump();
        await tester.idle();
      });
    }
  });
}
