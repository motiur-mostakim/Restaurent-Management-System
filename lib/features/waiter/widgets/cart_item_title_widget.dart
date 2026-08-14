import 'package:flutter/material.dart';

import '../../../model/menu_item.dart';
import 'quantity_button_widget.dart';

class CartItemTitleWidget extends StatelessWidget {
  final CartItem item;
  final Function(int) onUpdate;
  final VoidCallback onRemove;
  final String Function(double) formatCurrency;

  const CartItemTitleWidget({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onRemove,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              image: item.image != null && item.image!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.image == null || item.image!.isEmpty
                ? const Icon(
                    Icons.restaurant_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatCurrency(item.price),
                  style: const TextStyle(
                    color: Color(0xFFFF4F18),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              QuantityButtonWidget(
                icon: Icons.remove_rounded,
                onTap: () => onUpdate(-1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "${item.quantity}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              QuantityButtonWidget(
                icon: Icons.add_rounded,
                onTap: () => onUpdate(1),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFFCBD5E1),
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
