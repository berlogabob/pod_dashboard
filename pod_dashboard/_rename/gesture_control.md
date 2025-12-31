import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class GestureControl extends StatefulWidget {
  final DatabaseReference clawPodRef;

  const GestureControl({super.key, required this.clawPodRef});

  @override
  State<GestureControl> createState() => _GestureControlState();
}

class _GestureControlState extends State<GestureControl> {
  bool isEnabled = false;
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'gestureHandler',
        onMessageReceived: (JavaScriptMessage message) {
          String gesture = message.message;
          if (gesture == 'thumbs_up') {
            widget.clawPodRef.child('lock_state').set(3);
          } else if (gesture == 'thumbs_down') {
            widget.clawPodRef.child('lock_state').set(1);
          }
        },
      );
  }

  void _loadCamera() {
    controller.loadFlutterAsset('assets/hand_gesture.html');
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
                  onPressed: () {
                    setState(() {
                      isEnabled = !isEnabled;
                      if (isEnabled) {
                        _loadCamera();
                      }
                    });
                  },
                  child: Text(isEnabled ? 'Disable' : 'Enable'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isEnabled)
              SizedBox(
                width: 300,
                height: 300,
                child: WebViewWidget(controller: controller),
              ),
          ],
        ),
      ),
    );
  }
}