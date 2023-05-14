import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  late final InputDecoration inputDecoration;
final bool isPassword;
  CustomTextField({super.key, required this.hintText, this.isPassword=false}) {
    inputDecoration = InputDecoration(
        hintText: hintText,
        border: const UnderlineInputBorder()
    );
  }

  @override
  Widget build(BuildContext context ) {
    return TextField(
      style: const TextStyle(fontSize: 25),
      decoration: inputDecoration,
      obscureText: isPassword,
    );
  }


}