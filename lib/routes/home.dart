import 'package:flutter/material.dart';
import '../components/defaultButton.dart';
import '../components/popupBtn.dart';
import '../components/logo.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
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
                      DefaultButton(
                          text: 'Log in',
                          onPress: () => {Navigator.pushNamed(context, '/login')}
                      ),
                      const SizedBox(height: 20,),
                      DefaultButton(
                          text: "Sign up",
                          onPress: () => {Navigator.pushNamed(context, '/signup')}
                      ),
                      const SizedBox(height: 20,),
                      DefaultButton(
                          text: "List users",
                          onPress: () => {Navigator.pushNamed(context, '/listusers')}

                      ),
                      const SizedBox(height: 20,),
                      const PopupButton()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}