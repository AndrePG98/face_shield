import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_shield/components/defaultButton.dart';
import 'package:face_shield/routes/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:face_shield/components/customTextField.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helpers/Helpers.dart';
import '../services/api.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
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
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                  labelText: "Email", prefixIcon: Icon(Icons.mail)),
                              validator: (String? value) {
                                if (value!.trim().isEmpty) {
                                  return 'Email is required!';
                                } else if (!isValidEmail(value)) {
                                  return "Invalid Email";
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                setState(() {
                                  _formKey.currentState!.validate();
                                });
                              },
                            ),
                            const SizedBox(height: 25),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                      icon: Icon(_isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off))),
                              validator: (String? value) {
                                if (value!.trim().isEmpty) {
                                  return 'Password is required!';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                setState(() {
                                  _formKey.currentState!.validate();
                                });
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  logIn(_emailController.text,
                                      _passwordController.text);
                                  Navigator.pushNamed(context, '/editemail');
                                },
                                child: const Text("Login", style: TextStyle(fontSize: 18)),)
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
