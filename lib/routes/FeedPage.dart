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

  Future<String?> _getPicturePath(context) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final String? path = ModalRoute.of(context)?.settings.arguments as String?;
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String?>(
        future: _getPicturePath(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final picturePath = snapshot.data!;
            return Center(
                child: Image.file(
                  File(picturePath),
                  fit: BoxFit.contain,
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
