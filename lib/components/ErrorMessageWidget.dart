import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatefulWidget {
  final String message;

  const ErrorMessageWidget({super.key, required this.message});

  @override
  _ErrorMessageWidgetState createState() => _ErrorMessageWidgetState();
}

class _ErrorMessageWidgetState extends State<ErrorMessageWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacityAnimation.value,
      duration: Duration(seconds: 1),
      child: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16.0),
        child: Text(
          widget.message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
