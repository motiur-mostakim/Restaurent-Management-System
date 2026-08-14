import 'package:flutter/material.dart';

class OrderStatusWidget extends StatelessWidget {
  final String status;
  final bool allReady;

  const OrderStatusWidget({super.key, required this.status, required this.allReady});

  @override
  Widget build(BuildContext context) {
    bool isCompleted = status == 'delivered';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFEFF6FF)
            : (allReady ? const Color(0xFF22C55E) : const Color(0xFF0F172A)),
      ),
      child: Center(
        child: Text(
          isCompleted
              ? "ORDER COMPLETED"
              : (allReady ? "READY FOR SERVICE" : "PREPARATION IN PROGRESS"),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isCompleted ? const Color(0xFF1D4ED8) : Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
