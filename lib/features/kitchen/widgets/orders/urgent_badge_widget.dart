import 'package:flutter/material.dart';

class UrgentBadgeWidget extends StatelessWidget {
  final int waitTime;
  final bool isUrgent;

  const UrgentBadgeWidget({super.key, required this.waitTime, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red[100] : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_filled_rounded,
            size: 14,
            color: isUrgent ? Colors.red[700] : Colors.amber[800],
          ),
          const SizedBox(width: 4),
          Text(
            "${waitTime}m",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isUrgent ? Colors.red[700] : Colors.amber[900],
            ),
          ),
        ],
      ),
    );
  }
}