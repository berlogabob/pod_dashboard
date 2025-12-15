// lib/pod_content.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'timestamp.dart';
import 'sensor_box.dart';

class PodContent extends StatelessWidget {
  final DatabaseReference podRef;

  const PodContent({super.key, required this.podRef});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _lightSensorGrid(podRef)),
                const SizedBox(width: 24),
                Expanded(child: TimestampWidget(podRef: podRef)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _placeholder('Remote Actions')),
                const SizedBox(width: 24),
                Expanded(child: _placeholder('Occupancy Forecast (24h)')),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _placeholder('Slot 04 Details')),
                const SizedBox(width: 24),
                Expanded(child: _placeholder('Future Card')),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _lightSensorGrid(DatabaseReference podRef) {
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Light sensor data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // centered title
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: SensorBox(
                            sensorId: 'sensor0',
                            label: 'SL01',
                            podRef: podRef)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: SensorBox(
                            sensorId: 'sensor1',
                            label: 'SL02',
                            podRef: podRef)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: SensorBox(
                            sensorId: 'sensor2',
                            label: 'SL03',
                            podRef: podRef)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: SensorBox(
                            sensorId: 'sensor3',
                            label: 'SL04',
                            podRef: podRef)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String title) {
    return Container(
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
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
