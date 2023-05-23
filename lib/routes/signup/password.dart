import 'package:flutter/material.dart';
import '../../components/defaultButton.dart';
import '../../components/logo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:face_shield/components/signinField.dart';

class Username extends StatelessWidget{
  const Username({super.key});

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
                      SignInField(hintText: 'Password', controller: TextEditingController()),
                      const SizedBox(height: 50),
                      SignInField(hintText: 'Repeat password', controller:  TextEditingController()),
                    ],
                  )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                  onPressed: () => {Navigator.pop(context)}
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowRight),
                  onPressed: () => {
                    // Insert image API here
                  }
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}


