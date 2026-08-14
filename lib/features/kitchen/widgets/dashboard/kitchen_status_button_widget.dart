import 'package:flutter/material.dart';

class KitchenStatusButtonWidget extends StatelessWidget {
  final String status;
  final VoidCallback onToggle;

  const KitchenStatusButtonWidget({super.key, required this.status, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isReady = status == 'ready' || status == 'delivered';
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isReady ? const Color(0xFF22C55E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isReady ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isReady)
              const Icon(Icons.check_rounded, color: Colors.white, size: 16),
            if (isReady) const SizedBox(width: 6),
            Text(
              isReady ? "READY" : "MARK READY",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isReady ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}