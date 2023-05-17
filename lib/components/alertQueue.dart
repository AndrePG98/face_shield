import 'dart:collection';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class AlertQueue extends StatefulWidget {

  late final Queue<String> alertQueue = Queue();
  String currentPrompt = "";
  late bool accepted = false;
  bool isVisible = false;
  bool getNext = false;

  AlertQueue({super.key}){
    alertQueue.add("Smile");
    alertQueue.add("Look Left");
    alertQueue.add("Look Right");
  }

  @override
  AlertQueueState createState() => AlertQueueState();
}

class AlertQueueState extends State<AlertQueue> with SingleTickerProviderStateMixin{

  late AnimationController _controller;

  AlertQueueState(){
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void initState(){
    super.initState();
    widget.currentPrompt = widget.alertQueue.removeFirst();
  }

  void showNextAlert() async{
    if(widget.alertQueue.isEmpty) {
      setState(() {
        widget.accepted = true;
        widget.isVisible = false;
      });
      return;
    } else if(widget.getNext){
      setState(() {
        widget.currentPrompt = widget.alertQueue.removeFirst();
        widget.getNext = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    AnimatedBuilder promptDialog = AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context , Widget? child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0,0), end: const Offset(1,0)).animate(_controller),
          child: AnimatedOpacity(
              opacity: widget.isVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              curve: Curves.decelerate,
              child: child),
        );
      },
      child: Positioned(
            top: screenSize.height*.8,
            left: screenSize.width*0,
            child: AlertDialog(content: Text(widget.currentPrompt))
        ),
    );
    return promptDialog;
  }
}