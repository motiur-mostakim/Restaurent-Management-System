import 'package:flutter/material.dart';

class WaiterReportCardStatusBadge extends StatelessWidget {
  final String status;

  const WaiterReportCardStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    switch (status) {
      case 'ready':
        color = const Color(0xFF166534);
        bg = const Color(0xFFDCFCE7);
        break;
      case 'pending':
        color = const Color(0xFF9A3412);
        bg = const Color(0xFFFFEDD5);
        break;
      case 'delivered':
        color = const Color(0xFF64748B);
        bg = const Color(0xFFF1F5F9);
        break;
      default:
        color = const Color(0xFF1D4ED8);
        bg = const Color(0xFFEFF6FF);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}