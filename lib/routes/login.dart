import 'dart:async';

import 'package:face_shield/components/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:face_shield/components/signinField.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LogIn extends StatefulWidget{

  const LogIn({super.key});


  @override
  State<StatefulWidget> createState(){
    return LogInState();
  }
}

class LogInState extends State<LogIn> {
  late TextEditingController usernameController = TextEditingController();
  late bool isVisible = false;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    Size screenSize = MediaQuery.of(context).size;
    SignInField field = SignInField(hintText: 'Username',controller: usernameController,);
    Positioned alertDialog = Positioned(
      top: screenSize.height*.5,
      left: screenSize.width*0,
      child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: const Duration(seconds: 1),
          curve: Curves.decelerate,
          child: const AlertDialog(content: Text('Must insert Username', textAlign: TextAlign.center, style: TextStyle(fontSize: 20),))
      ),
    );
    return Scaffold(
      body: Center(
        child : Stack(
          children: [
            Column(
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
                              field,
                              const SizedBox(height: 25),
                            ],
                          ),
                          const SizedBox(height: 25),
                        ],
                      )
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DefaultButton(text: "Log in ", onPress: () {
                      if(usernameController.text != '') {
                        Navigator.pushNamed(context, '/camera', arguments: usernameController.text);
                      } else {
                        setState(() {
                          isVisible = true;
                          Future.delayed(
                              const Duration(seconds: 2),
                                  () => { setState(() => isVisible = false)}
                          );
                        });
                      }
                    })
                  ],
                ),
              ],
            ),
            alertDialog
          ],
        )
      ),
    );
  }

}



