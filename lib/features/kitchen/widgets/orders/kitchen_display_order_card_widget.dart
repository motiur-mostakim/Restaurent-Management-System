import 'package:flutter/material.dart';

import '../../../../model/order_model.dart';
import 'order_item_widget.dart';
import 'order_notes_widget.dart';
import 'order_progressbar_widget.dart';
import 'order_status_widget.dart';
import 'urgent_badge_widget.dart';

class KitchenDisplayOrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final String vendorType;
  final Function(int, String) onUpdateStatus;

  const KitchenDisplayOrderCardWidget({super.key,
    required this.order,
    required this.vendorType,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final waitTime = DateTime.now().difference(order.createdAt).inMinutes;
    final vendorItems = vendorType.isEmpty
        ? order.items
        : order.items.where((i) => i.vendorId == vendorType).toList();

    final readyItemsCount = vendorItems
        .where((i) => i.status == 'ready' || i.status == 'delivered')
        .length;
    final allReady = readyItemsCount == vendorItems.length;
    final isUrgent = waitTime > 15 && !allReady;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isUrgent
                ? Colors.red.withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isUrgent
              ? Colors.red.withOpacity(0.3)
              : const Color(0xFFE2E8F0),
          width: isUrgent ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUrgent
                  ? const Color(0xFFFFF1F2)
                  : const Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(
                  color: isUrgent ? Colors.red[50]! : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.red : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          order.tableNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TABLE UNIT",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF64748B),
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "#${order.id.substring(order.id.length.clamp(0, 4) == 4 ? order.id.length - 4 : 0).toUpperCase()}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                UrgentBadgeWidget(waitTime: waitTime, isUrgent: isUrgent),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (vendorItems.length > 1)
                OrderProgressbarWidget(
                  ready: readyItemsCount,
                  total: vendorItems.length,
                ),
              if (order.notes?.isNotEmpty ?? false)
                OrderNotesWidget(notes: order.notes!),
              ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vendorItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = vendorItems[index];
                  final originalIdx = order.items.indexOf(item);
                  return OrderItemWidget(
                    item: item,
                    onStatusToggle: () => onUpdateStatus(
                      originalIdx,
                      item.status == 'preparing' ? 'ready' : 'preparing',
                    ),
                    canEdit: order.status != 'delivered',
                  );
                },
              ),
            ],
          ),
          OrderStatusWidget(status: order.status, allReady: allReady),
        ],
      ),
    );
  }
}
