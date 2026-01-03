import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'sensor_box.dart';
import 'status_panel.dart';
import 'remote_actions.dart';
import 'light_settings.dart';
import 'network_panel.dart';

class PodContent extends StatelessWidget {
  final DatabaseReference lightPodRef;
  final DatabaseReference lockerPodRef;
  final bool isPhonePortrait; // новый флаг

  const PodContent({
    super.key,
    required this.lightPodRef,
    required this.lockerPodRef,
    this.isPhonePortrait = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget lightSensorGrid = _lightSensorGrid(lightPodRef);
    Widget statusPanel = StatusPanel(podRef: lightPodRef);
    Widget remoteActions =
        RemoteActions(lightPodRef: lightPodRef, lockerPodRef: lockerPodRef);
    Widget lightSettings = LightSettings(podRef: lightPodRef);
    Widget networkPanel = const NetworkPanel();

    if (isPhonePortrait) {
      // На телефоне — всё в столбец
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            lightSensorGrid,
            const SizedBox(height: 24),
            statusPanel,
            const SizedBox(height: 24),
            remoteActions,
            const SizedBox(height: 24),
            lightSettings,
            const SizedBox(height: 24),
            networkPanel,
            const SizedBox(height: 40),
          ],
        ),
      );
    } else {
      // На большом экране — Row как было
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: lightSensorGrid),
                const SizedBox(width: 24),
                Expanded(child: statusPanel),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: remoteActions),
                const SizedBox(width: 24),
                Expanded(child: lightSettings),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _placeholder('Slot 04 Details')),
                const SizedBox(width: 24),
                Expanded(child: networkPanel),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }
  }

  Widget _lightSensorGrid(DatabaseReference podRef) {
    // оставляем как было
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Light sensor data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
            color: Colors.grey.withValues(alpha: 0.15),
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
