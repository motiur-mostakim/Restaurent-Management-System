import 'package:flutter/material.dart';

import '../../../../model/order_model.dart';

class OrderItemWidget extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onStatusToggle;
  final bool canEdit;

  const OrderItemWidget({super.key,
    required this.item,
    required this.onStatusToggle,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = item.status == 'ready' || item.status == 'delivered';
    final isPreparing = item.status == 'preparing';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReady ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReady ? const Color(0xFFBBF7D0) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isReady ? Colors.green[500] : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${item.quantity}x",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isReady
                        ? const Color(0xFF166534)
                        : const Color(0xFF1E293B),
                    decoration: isReady ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isReady
                        ? Colors.green[600]
                        : (isPreparing
                        ? Colors.orange[700]
                        : Colors.blueGrey[300]),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (!isReady && canEdit)
            _ActionIcon(onTap: onStatusToggle, isPreparing: isPreparing),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final VoidCallback onTap;
  final bool isPreparing;

  const _ActionIcon({required this.onTap, required this.isPreparing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isPreparing ? Colors.green[600] : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isPreparing ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}