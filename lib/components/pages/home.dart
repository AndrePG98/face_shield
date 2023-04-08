import 'package:face_shield/components/pages/signin.dart';
import 'package:flutter/material.dart';
import '../buttons/homepageBtn.dart';
import '../icons/logo.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              flex: 3,
              child: Logo(),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomePageBtn(
                      text: 'Sign in',
                      onPress: () => {
                        Navigator.popAndPushNamed(context, '/signin')
                      }
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}