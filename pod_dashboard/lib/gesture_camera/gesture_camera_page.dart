import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';

import 'camera_page.dart';

class GestureCameraPage extends StatefulWidget {
  final DatabaseReference clawPodRef;

  const GestureCameraPage({super.key, required this.clawPodRef});

  @override
  State<GestureCameraPage> createState() => _GestureCameraPageState();
}

class _GestureCameraPageState extends State<GestureCameraPage> {
  late List<CameraDescription> cameras;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initCameras();
  }

  Future<void> initCameras() async {
    cameras = await availableCameras();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (cameras.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No camera found')),
      );
    }
    return CameraHomePage(
      cameras: cameras,
      clawPodRef: widget.clawPodRef,
    );
  }
}
