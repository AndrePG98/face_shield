import 'package:flutter/material.dart';

class DefaultButton extends StatefulWidget {
  final String text;
  final void Function() onPress;

  const DefaultButton({super.key, required this.text, required this.onPress});

  @override
  State<StatefulWidget> createState() => _DefaultBtnState();
}

class _DefaultBtnState extends State<DefaultButton> {
  late final String _text;
  late final Function() _onPress;

  late final ButtonStyle homePageBtnStyle = ButtonStyle(
    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
    minimumSize: MaterialStateProperty.all<Size>(const Size(150,50)),
    maximumSize: MaterialStateProperty.all<Size>(const Size(150,50)),
    textStyle: MaterialStateProperty.all<TextStyle>(const TextStyle(fontSize: 25.0)),
  );

  @override
  void initState(){
    super.initState();
    _text = widget.text;
    _onPress = widget.onPress;
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: homePageBtnStyle, // Use the defined ButtonStyle
      onPressed: _onPress,
      child: Text(
        _text,
        maxLines: 1,
      ),
    );
  }
}
