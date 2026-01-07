import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'side_menu.dart';
import 'top_bar.dart';
import 'pod_content.dart';
import 'online_chip.dart';
import 'claw_control.dart';
import 'gesture_control.dart';
import 'gesture_camera_test_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBydwUR2hcQgpyMbcCTiRH86gWZaDKKXR4",
      authDomain: "booking-ee47f.firebaseapp.com",
      databaseURL:
          "https://booking-ee47f-default-rtdb.europe-west1.firebasedatabase.app",
      projectId: "booking-ee47f",
      storageBucket: "booking-ee47f.firebasestorage.app",
      messagingSenderId: "297718966154",
      appId: "1:297718966154:web:b2c07b0d9a1fdfb6f8ca73",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/parking_spot': (context) => const ParkingSpotPage(),
       // '/test_camera': (context) => GestureCameraTestPage(),
      },
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference basePodRef =
        FirebaseDatabase.instance.ref('devices/Pod_01_base_01');
    final DatabaseReference entradaPodRef =
        FirebaseDatabase.instance.ref('devices/Pod_01_entrada_01');

    bool isPhonePortrait = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Row(
          children: [
            SideMenu(collapsed: isPhonePortrait, selectedItem: 'Dashboard'),
            Expanded(
              child: Column(
                children: [
                  TopBar(smallScreen: isPhonePortrait),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/test_camera');
                    },
                    child: const Text('TEST GESTURE CAMERA FULLSCREEN'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: isPhonePortrait
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pod Control',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Icon(Icons.star_border,
                                      size: 20, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('IADE Central Hub',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(Icons.description_outlined,
                                      size: 20, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('Firmware: v2.3.1',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              OnlineChip(podRef: basePodRef),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pod Control',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: const [
                                      Icon(Icons.star_border,
                                          size: 20, color: Colors.grey),
                                      SizedBox(width: 8),
                                      Text('IADE Central Hub',
                                          style: TextStyle(color: Colors.grey)),
                                      SizedBox(width: 20),
                                      Icon(Icons.description_outlined,
                                          size: 20, color: Colors.grey),
                                      SizedBox(width: 8),
                                      Text('Firmware: v2.3.1',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                              OnlineChip(podRef: basePodRef),
                            ],
                          ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: PodContent(
                        lightPodRef: basePodRef,
                        lockerPodRef: entradaPodRef,
                        isPhonePortrait: isPhonePortrait,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParkingSpotPage extends StatelessWidget {
  const ParkingSpotPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isPhonePortrait = MediaQuery.of(context).size.width < 600;

    final DatabaseReference clawPodRef =
        FirebaseDatabase.instance.ref('devices/Pod_01_Claw_01');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Row(
          children: [
            SideMenu(collapsed: isPhonePortrait, selectedItem: 'Parking Spot'),
            Expanded(
              child: Column(
                children: [
                  TopBar(smallScreen: isPhonePortrait),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: isPhonePortrait
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Parking Spot Control',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OnlineChip(podRef: clawPodRef),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Parking Spot Control',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              OnlineChip(podRef: clawPodRef),
                            ],
                          ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ClawControl(clawPodRef: clawPodRef),
                          GestureControl(clawPodRef: clawPodRef),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
