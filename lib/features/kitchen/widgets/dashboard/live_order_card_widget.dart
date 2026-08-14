import 'package:flutter/material.dart';

import '../../../../model/order_model.dart';
import 'kitchen_status_button_widget.dart';

class LiveOrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final String vendorType;
  final Color primaryColor;
  final Function(int, String) onUpdateStatus;

  const LiveOrderCardWidget({super.key,
    required this.order,
    required this.vendorType,
    required this.primaryColor,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final waitTime = DateTime.now().difference(order.createdAt).inMinutes;
    final vendorItems = order.items
        .where((i) => i.vendorId == vendorType || vendorType.isEmpty)
        .toList();
    final isUrgent = waitTime > 15 && order.status != 'delivered';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isUrgent ? Colors.red.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "${order.tableNumber}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Table ${order.tableNumber}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "#${order.id.substring(order.id.length - 6).toUpperCase()}",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red[50] : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: 16,
                        color: isUrgent ? Colors.red : Colors.green[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${waitTime}m",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: isUrgent ? Colors.red : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 24, endIndent: 24),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vendorItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final item = vendorItems[idx];
                final actualIndex = order.items.indexOf(item);
                final isItemReady =
                    item.status == 'ready' || item.status == 'delivered';

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${item.quantity}x",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: isItemReady
                              ? TextDecoration.lineThrough
                              : null,
                          color: isItemReady
                              ? Colors.grey
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    KitchenStatusButtonWidget(
                      status: item.status,
                      onToggle: () {
                        final newStatus = item.status == 'ready'
                            ? 'pending'
                            : 'ready';
                        onUpdateStatus(actualIndex, newStatus);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          if (order.notes != null && order.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Colors.amber[900],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber[900],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}