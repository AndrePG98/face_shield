import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_shield/components/defaultButton.dart';
import 'package:face_shield/routes/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:face_shield/components/customTextField.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/api.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Center(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(labelText: "Email"),
                          ),
                          const SizedBox(height: 25),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(labelText: "Password"),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                logIn(_emailController.text,
                                    _passwordController.text);
                                Navigator.pushNamed(context, '/editemail');
                              },
                              child: Text("Login"))
                        ],
                      ),
                      const SizedBox(height: 25),
                    ],
                  )),
            ),
            Row(
              children: [
                IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                    onPressed: () => {Navigator.pop(context)}),
                DefaultButton(
                    text: "Test",
                    onPress: () {
                      Navigator.pushNamed(context, '/camera');
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
