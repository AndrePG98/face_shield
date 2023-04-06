import 'package:face_shield/components/pages/home.dart';
import 'package:flutter/material.dart';
import '../homepageBtn.dart';
import '../logo.dart';

class SignIn extends StatelessWidget{
  const SignIn({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget> [
            const Icon(
              Icons.account_circle_rounded,
              color: Colors.white,
              size: 150,
            ),
            HomePageBtn(
              text: 'Back',
              onPress: () => {
                Navigator.pushNamed(context, '/')
              },
            ),
          ],
        ),
      ),
    );
  }
}