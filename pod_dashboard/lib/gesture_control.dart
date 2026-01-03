import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../pages/gesture_camera_page.dart'; // Import the page
import '../main.dart';

class GestureControl extends StatelessWidget {
  final DatabaseReference clawPodRef;

  const GestureControl({super.key, required this.clawPodRef});

  void _openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GestureCameraPage(
          clawPodRef: clawPodRef,
          cameras: cameras,
        ),
      ),
    );
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
            color: Colors.grey.withValues(alpha: 0.15),
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
            const Text(
              'Gesture Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _openCamera(context),
                icon: const Icon(Icons.camera_alt, size: 32),
                label: const Text(
                  'Start Gesture Detection',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
