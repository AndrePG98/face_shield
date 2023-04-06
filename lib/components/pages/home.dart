import 'package:face_shield/components/pages/signin.dart';
import 'package:flutter/material.dart';
import '../homepageBtn.dart';
import '../logo.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Logo(),
            const SizedBox(height: 40),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                HomePageBtn(
                    text: 'Sign in',
                    onPress: () => {
                      Navigator.pushNamed(context, '/signin')
                    }
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}