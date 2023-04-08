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
    return ElevatedButton(
      style: homePageBtnStyle,
      onPressed: _onPress,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          _text,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black
          ),
        ),
      ),
    );
  }
}


ButtonStyle homePageBtnStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)){
        return Colors.lightBlue[400];
      }
      return Colors.lightBlue[50];
    }
  ),
  elevation: MaterialStateProperty.all<double?>(50),
  minimumSize: MaterialStateProperty.all<Size>(const Size(200, 3)),
  shape: MaterialStateProperty.all<OutlinedBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
      side: const BorderSide(
        width: .5,
        style: BorderStyle.solid,
        color: Colors.black
      )
    )
  )
);