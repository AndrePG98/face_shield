import 'dart:collection';

import 'package:camera/camera.dart';
import 'package:face_shield/components/proofOfLifeAlert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertQueue extends StatefulWidget{

  late final Queue<ProofOfLifeAlert> alertQueue;
  late bool accepted = false;

  AlertQueue({super.key}){
    alertQueue.add(ProofOfLifeAlert(prompt: "Smile",  isVisible: true));
    alertQueue.add(ProofOfLifeAlert(prompt: "Look left", isVisible: false));
    alertQueue.add(ProofOfLifeAlert(prompt: 'Look right', isVisible: false));
  }

  @override
  AlertQueueState createState() => AlertQueueState();
}

class AlertQueueState extends State<AlertQueue>{

  late ProofOfLifeAlert currentAlert;
  String currentPrompt = "";

  @override
  void initState(){
    super.initState();
  }

  void showNextAlert(CameraImage image) async{
    if(widget.alertQueue.isEmpty) {
      widget.accepted = true;
      return;
    }
    currentAlert.isVisible = false;
    currentAlert = widget.alertQueue.removeFirst();
    currentAlert.isVisible = true;
    currentPrompt = currentAlert.prompt;
  }

  @override
  Widget build(BuildContext context) {
    currentAlert = widget.alertQueue.removeFirst();
    Size screenSize = MediaQuery.of(context).size;
    Positioned promptDialog = Positioned(
      top: screenSize.height*.8,
      left: screenSize.width*0,
      child: AnimatedOpacity(
          opacity: currentAlert.isVisible ? 1.0 : 0.0,
          duration: const Duration(seconds: 1),
          curve: Curves.decelerate,
          child: AlertDialog(content: Text(currentPrompt)))
      );
    return promptDialog;
  }
}