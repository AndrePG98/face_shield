import 'package:flutter/material.dart';

class HomePageBtn extends StatefulWidget {
  final String text;
  final void Function() onPress;

  const HomePageBtn({super.key, required this.text, required this.onPress});

  @override
  State<StatefulWidget> createState() => _HomePageBtnState();
}

class _HomePageBtnState extends State<HomePageBtn> {
  late final String _text;
  late final Function() _onPress;

  @override
  void initState(){
    super.initState();
    _text = widget.text;
    _onPress = widget.onPress;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)){
                return Colors.black;
              }
              return Colors.lightBlue[50];
            }
        ),
        elevation: MaterialStateProperty.all<double?>(2.0),
      ),
      onPressed: _onPress,
      child: Text(_text),
    );
  }
}