// lib/sensor_box.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SensorBox extends StatefulWidget {
  final String sensorId;
  final String label;
  final DatabaseReference podRef;

  const SensorBox({
    super.key,
    required this.sensorId,
    required this.label,
    required this.podRef,
  });

  @override
  State<SensorBox> createState() => _SensorBoxState();
}

class _SensorBoxState extends State<SensorBox> {
  int value = 0;

  @override
  void initState() {
    super.initState();

    widget.podRef
        .child('sensors/sensors_data/${widget.sensorId}')
        .onValue
        .listen((event) {
      final val = event.snapshot.value as int?;
      if (val != null) {
        setState(() {
          value = val;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // center horizontally
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
