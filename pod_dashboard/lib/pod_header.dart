// lib/pod_header.dart

import 'package:flutter/material.dart';

class PodHeader extends StatelessWidget {
  const PodHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      color: const Color(0xFFF5F5F5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool smallScreen = constraints.maxWidth < 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Online chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pod Control: POD-GCT-001A',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _onlineChip(),
                ],
              ),
              const SizedBox(height: 12),

              // Subtitle – adaptive
              if (smallScreen)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subtitleRow('IADE Central Hub'),
                    const SizedBox(height: 8),
                    _subtitleRow('Firmware: v2.3.1'),
                  ],
                )
              else
                Row(
                  children: [
                    _subtitleRow('IADE Central Hub'),
                    const SizedBox(width: 20),
                    _subtitleRow('Firmware: v2.3.1'),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _onlineChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.green[700], size: 12),
          const SizedBox(width: 8),
          Text(
            'Online',
            style: TextStyle(
                color: Colors.green[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _subtitleRow(String text) {
    return Row(
      children: [
        Icon(Icons.star_border, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
