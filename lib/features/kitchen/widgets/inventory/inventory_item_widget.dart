import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../model/menu_item.dart';
import '../../../../provider/menu_provider.dart';

class InventoryItemWidget extends StatelessWidget {
  final MenuItem item;
  final MenuProvider provider;
  final Color primaryColor;

  const InventoryItemWidget({
    super.key,
    required this.item,
    required this.provider,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    String formatCurrency(double amount) {
      return NumberFormat.currency(
        symbol: '৳',
        decimalDigits: 0,
      ).format(amount);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFF8FAFC),
                        image: (item.image != null && item.image!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(item.image!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (item.image == null || item.image!.isEmpty)
                          ? const Icon(
                              Icons.restaurant_menu_rounded,
                              color: Color(0xFFCBD5E1),
                              size: 30,
                            )
                          : null,
                    ),
                    if (!item.available)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.block_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(item.price),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch.adaptive(
                      value: item.available,
                      activeColor: primaryColor,
                      onChanged: (val) => provider.toggleAvailability(item),
                    ),
                    Text(
                      item.available ? "AVAILABLE" : "SOLD OUT",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: item.available
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
