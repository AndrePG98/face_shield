import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/Helpers.dart';
import '../services/api.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
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
                    height: 16,
                  ),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _loading = true;
                              });
                              signUp(_emailController.text,
                                      _passwordController.text)
                                  .then((value) => {
                                        if (value)
                                          {
                                            setState(() {
                                              _loading = false;
                                            }),
                                            _emailController.clear(),
                                            _passwordController.clear(),
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "User created successfuly!"))),
                                          }
                                        else
                                          {
                                            setState(() {
                                              _loading = false;
                                            }),
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Error creating the user. Email already in use!"))),
                                          }
                                      });
                            }
                          },
                          child: const Text("Create Account"))
                ],
              ),
            )));
  }
}
