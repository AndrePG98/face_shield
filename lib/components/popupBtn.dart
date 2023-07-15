import 'dart:math';

import 'package:face_shield/components/defaultButton.dart';
import 'package:flutter/material.dart';

class PopupButton extends StatefulWidget {
  const PopupButton({super.key});

  @override
  State<StatefulWidget> createState() => _PopupButtonState();
}

class _PopupButtonState extends State<PopupButton> {
  void _showPopup(int success) {
    IconData visibleIcon = success == 1 ? Icons.check_circle : Icons.cancel;
    Color iconColor = success == 1 ? Colors.green : Colors.red;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: const BoxDecoration(color: Colors.transparent),
            padding: const EdgeInsets.all(16),
            child: Icon(
              visibleIcon,
              color: iconColor,
              size: 150,
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultButton(
      text: 'Check',
      onPress: () => {_showPopup(Random().nextInt(2))},
    );
  }
}
