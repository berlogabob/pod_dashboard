import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'gesture_camera/camera_page.dart'; // your CameraHomePage is here

class GestureCameraTestPage extends StatefulWidget {
  const GestureCameraTestPage({super.key});

  @override
  State<GestureCameraTestPage> createState() => _GestureCameraTestPageState();
}

class _GestureCameraTestPageState extends State<GestureCameraTestPage> {
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    initCameras();
  }

  Future<void> initCameras() async {
    cameras = await availableCameras();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return CameraHomePage(cameras: cameras);
  }
}
