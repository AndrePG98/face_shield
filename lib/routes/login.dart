import 'package:face_shield/components/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:face_shield/components/signinField.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LogIn extends StatelessWidget{
  const LogIn({super.key});

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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SignInField(hintText: 'Username'),
                        const SizedBox(height: 25),
                      ],
                    ),
                    const SizedBox(height: 25),
                  ],
                )
              ),
            ),
            Row(
             children: [
               IconButton(
                   icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                   onPressed: () => {Navigator.pop(context)}
               ),
               DefaultButton(text: "Test", onPress: () {Navigator.pushNamed(context, '/camera');})
             ], 
            )
          ],
        ),
      ),
    );
  }
}


