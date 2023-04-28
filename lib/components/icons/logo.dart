import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: ResizeImage(
        AssetImage('assets/Logo.png'),
        width: 150,
        height: 150
      )
    );
  }
}