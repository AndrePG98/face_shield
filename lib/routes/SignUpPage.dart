import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/api.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign Up"),
        ),
        body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                ),
                SizedBox(
                  height: 16,
                ),
                _loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                          });
                          signUp(_emailController.text,
                                  _passwordController.text)
                              .then((value) => {
                                    setState(() {
                                      _loading = false;
                                    }),
                            _emailController.clear(),
                            _passwordController.clear(),
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Utilizador criado com sucesso!"))),
                                  });
                        },
                        child: Text("Create Account"))
              ],
            )));
  }
}
