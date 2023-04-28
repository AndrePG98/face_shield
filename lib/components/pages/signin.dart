import 'package:face_shield/components/pages/home.dart';
import 'package:flutter/material.dart';
import '../buttons/homepageBtn.dart';
import '../icons/logo.dart';

class SignIn extends StatelessWidget{
  const SignIn({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget> [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SignInField(hintText: 'Username'),
                    const SizedBox(height: 25),
                    SignInField(hintText: 'Password')
                  ],
                )
              ),
            ),
            BackButton(
              color: Colors.white,
              onPressed: () => {Navigator.popAndPushNamed(context, '/')}
            )
          ],
        ),
      ),
    );
  }
}

class SignInField extends StatelessWidget {
  final String hintText;
  late final InputDecoration inputDecoration;

  SignInField({super.key, required this.hintText}) {
    inputDecoration = InputDecoration(
        hintText: hintText,
        border: const UnderlineInputBorder()
    );
  }

  @override
  Widget build(BuildContext context ) {
    return TextField(
      decoration: inputDecoration,
    );
  }


}


