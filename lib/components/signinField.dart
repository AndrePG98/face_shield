import 'package:flutter/material.dart';

class SignInField extends StatelessWidget {
  final String hintText;
  late final InputDecoration inputDecoration;

  SignInField({super.key, required this.hintText}) {
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
    );
  }


}