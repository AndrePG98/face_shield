import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:face_shield/processors/CameraProcessor.dart';
import 'package:face_shield/processors/FaceProcessor.dart';
import 'package:flutter/material.dart';
import 'package:face_shield/services/api.dart' as api;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class SucessfulLoginWidget extends StatelessWidget {
  SucessfulLoginWidget({Key? key}) : super(key: key);

  Future<List> _getArguments(context) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final List<dynamic> list = ModalRoute.of(context)?.settings.arguments as List;
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List>(
        future: _getArguments(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final picturePath = snapshot.data?[0];
            final userEmail = snapshot.data?[1];
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: ClipOval(
                      child: picturePath != null && File(picturePath).existsSync()
                          ? Image.file(
                        File(picturePath),
                        fit: BoxFit.cover,
                      )
                          : Icon(
                        Icons.account_circle,
                        size: 200,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userEmail!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("Failed to load picture path."));
          }
        },
      ),
    );
  }
}

