import 'package:flutter/material.dart';

class AnimatedText extends StatelessWidget {
  final bool value;
  final String label;

  const AnimatedText({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: value ? Colors.green : Colors.transparent,
        border: Border.all(
          color: value ? Colors.black : Colors.white
        )
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        style: TextStyle(
          color: value ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}