import 'package:flutter/material.dart';

class SignInField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;

  const SignInField({super.key, required this.hintText, required this.controller});

  @override
  SignInFieldState createState() => SignInFieldState();
}

class SignInFieldState extends State<SignInField> {

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}