import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:face_shield/processors/FaceProcessor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class FeedPage extends StatelessWidget {
  FeedPage({Key? key}) : super(key: key);

  List<dynamic> argumentsList = [];


  Future<List> _getPicturePath(context) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final List<dynamic> list = ModalRoute.of(context)?.settings.arguments as List;
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List>(
        future: _getPicturePath(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final picturePath = snapshot.data?[0];
            final user = snapshot.data?[1];
            return Center(
                child: Stack(
                  children: [
                    Image.file(
                      File(picturePath),
                      fit: BoxFit.contain,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("$user"),
                    )
                  ],
                )
            );
          } else {
            return const Center(child: Text("Failed to load picture path."));
          }
        },
      ),
    );
  }
}
