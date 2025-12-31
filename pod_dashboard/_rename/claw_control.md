import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ClawControl extends StatefulWidget {
  final DatabaseReference clawPodRef;

  const ClawControl({super.key, required this.clawPodRef});

  @override
  State<ClawControl> createState() => _ClawControlState();
}

class _ClawControlState extends State<ClawControl> {
  int lockState = 0;

  @override
  void initState() {
    super.initState();

    widget.clawPodRef.child('lock_state').onValue.listen((event) {
      final val = event.snapshot.value as int? ?? 0;
      if (val >= 0 && val <= 3) {
        setState(() {
          lockState = val;
        });
      }
    });
  }

  Color getBaseColor() {
    switch (lockState) {
      case 0:
        return Colors.green[600]!;
      case 2:
        return Colors.red[600]!;
      case 1:
        return Colors.blue[600]!;
      case 3:
        return Colors.amber[700]!;
      default:
        return Colors.grey;
    }
  }

  String getButtonText() {
    return lockState == 2 ? 'Lock' : 'Unlock';
  }

  bool isProcessing() {
    return lockState == 1 || lockState == 3;
  }

  void _onTap() {
    if (isProcessing()) return;

    int newState = lockState == 0 ? 1 : 3;
    widget.clawPodRef.child('lock_state').set(newState);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _onTap,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: isProcessing()
                          ? getBaseColor().withAlpha(128)
                          : getBaseColor(),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        getButtonText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Opacity(
                  opacity: isProcessing() ? 1.0 : 0.0,
                  child: const CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}