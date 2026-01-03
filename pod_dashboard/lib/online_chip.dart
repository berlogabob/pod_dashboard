import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OnlineChip extends StatefulWidget {
  final DatabaseReference podRef;

  const OnlineChip({super.key, required this.podRef});

  @override
  State<OnlineChip> createState() => _OnlineChipState();
}

class _OnlineChipState extends State<OnlineChip> {
  int lastTimestamp = 0;
  int sendInterval = 5;
  bool isOnline = false;

  Timer? _timer;
  late StreamSubscription<DatabaseEvent> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = widget.podRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<Object?, Object?>?;
      if (data == null) return;

      int newTimestamp = data['timestamp'] as int? ?? 0;
      final settings = data['settings'] as Map<Object?, Object?>?;
      final conn = settings?['connection_package'] as Map<Object?, Object?>?;
      int newInterval = conn?['send_interval'] as int? ?? 5;

      if (!mounted) return;

      setState(() {
        lastTimestamp = newTimestamp;
        sendInterval = newInterval;
        isOnline = true;
      });

      _timer?.cancel();

      int maxWait = sendInterval * 10;
      _timer = Timer(Duration(seconds: maxWait), () {
        if (!mounted) return;
        setState(() {
          isOnline = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: isOnline ? Colors.green[700] : Colors.red[700],
            size: 12,
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: isOnline ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
