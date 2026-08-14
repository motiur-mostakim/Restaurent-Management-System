import 'package:flutter/material.dart';

class QuantityButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const QuantityButtonWidget({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF1E293B)),
      ),
    );
  }
}