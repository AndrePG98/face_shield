import 'package:flutter/material.dart';
import 'package:face_shield/components/signinField.dart';
import '../components/defaultButton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Recovery extends StatelessWidget{
  const Recovery({super.key});

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
                        SignInField(hintText: 'Email', controller: TextEditingController()),
                        const SizedBox(height: 35),
                        DefaultButton(
                          text: 'Continue',
                          onPress: () => {
                            // Search database for email
                            // Send recovery email
                            // route to page for setting new password
                          }
                        )
                      ],
                    ),
                  ]
                )
              ),
            ),
            IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: const FaIcon(FontAwesomeIcons.arrowLeft)
            )
          ],
        ),
      ),
    );
  }
}


