import 'package:flutter/material.dart';

import '../../kitchen_menu_screen.dart';

class KitchenDashboardInventoryAlertWidget extends StatelessWidget {
  final int count;

  const KitchenDashboardInventoryAlertWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const KitchenMenuScreen(initialAvailabilityFilter: 'Sold Out'),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Inventory Alert",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7F1D1D),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "$count items out of stock. Update kitchen menu.",
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.red[900]),
          ],
        ),
      ),
    );
  }
}
