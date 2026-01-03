import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';

import 'gesture_camera/gesture_camera_page.dart';

class GestureControl extends StatefulWidget {
  final DatabaseReference clawPodRef;

  const GestureControl({super.key, required this.clawPodRef});

  @override
  State<GestureControl> createState() => _GestureControlState();
}

class _GestureControlState extends State<GestureControl> {
  bool isLoading = false;

  Future<void> _openGestureCamera() async {
    setState(() {
      isLoading = true;
    });

    final status = await Permission.camera.request();
    if (status.isGranted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GestureCameraPage(clawPodRef: widget.clawPodRef),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission needed for gestures')),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gesture Control',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : _openGestureCamera,
                  child: Text(isLoading ? 'Opening...' : 'Enable'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Open camera and use hand gestures:\n👍 Unlock pod\n👎 Lock pod\n👌 (shown but no action)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}