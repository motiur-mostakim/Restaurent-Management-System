import 'package:flutter/material.dart';

class OrderProgressbarWidget extends StatelessWidget {
  final int ready;
  final int total;

  const OrderProgressbarWidget({
    super.key,
    required this.ready,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "PREPARATION",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1,
                ),
              ),
              Text(
                "$ready / $total",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ready / total,
              backgroundColor: const Color(0xFFF1F5F9),
              color: Colors.green[500],
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
