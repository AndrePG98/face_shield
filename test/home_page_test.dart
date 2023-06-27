import 'package:face_shield/components/logo.dart';
import 'package:face_shield/routes/ListUsersPage.dart';
import 'package:face_shield/routes/LogInDetectionRoute.dart';
import 'package:face_shield/routes/SignUpPage.dart';
import 'package:face_shield/routes/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
// TODO: later mock firebase
  //setUpAll(() async{
  //  WidgetsFlutterBinding.ensureInitialized();
  //  await Firebase.initializeApp(
  //    options: DefaultFirebaseOptions.currentPlatform,
  //  );
//
 // } );

  testWidgets('Home Page Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget( MaterialApp(home: HomePage(), routes: <String, WidgetBuilder> {
      '/login' : (BuildContext context) => LogInDetectionWidget(),
      '/signup' : (BuildContext context) => const SignUpPage(),
      '/listusers': (BuildContext context) => const ListUsersPage()
    },));

    //verificar se o logo está presente.
    expect(find.byType(Logo), findsOneWidget);

    //verificar que o default button está presente

    final Finder loginButton = find.widgetWithText(OutlinedButton, 'Log in');
    expect(loginButton, findsOneWidget);

    final Finder signUpButton = find.widgetWithText(OutlinedButton, 'Sign up');
    expect(signUpButton, findsOneWidget);

    final Finder listUsersButton = find.widgetWithText(OutlinedButton, 'List users');
    expect(listUsersButton, findsOneWidget);

    //simular que o botão foi clicado e verificar a sua navegação.
    //await tester.tap(loginButton);
    //await tester.pumpAndSettle();
    //expect(find.byType(LogIn), findsOneWidget);

    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpPage), findsOneWidget);

    //await tester.tap(listUsersButton);
   // await tester.pumpAndSettle();
   // expect(find.byType(ListUsersPage), findsOneWidget);
  });

}