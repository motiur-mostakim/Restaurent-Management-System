import 'package:flutter/material.dart';
import 'package:restaurant_management/provider/dashboard_provider.dart';
import 'package:restaurant_management/provider/kitchen_provider.dart';
import 'package:restaurant_management/provider/waiterProvider.dart';

class FilterWidget extends StatelessWidget {
  final DashboardProvider? provider;
  final WaiterProvider? waiterProvider;
  final KitchenProvider? kitchenProvider;
  final bool isForWaiter;
  final bool isForKitchen;

  const FilterWidget({
    super.key,
    this.provider,
    this.waiterProvider,
    this.kitchenProvider,
    required this.isForKitchen,
    required this.isForWaiter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isForWaiter == true
              ? waiterProvider?.dateFilter
              : isForKitchen == true
              ? kitchenProvider?.dateFilter
              : provider?.dateFilter,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Color(0xFF64748B),
          ),
          onChanged: (val) => val != null
              ? isForWaiter == true
                    ? waiterProvider?.setDateFilter(val)
                    : isForKitchen == true
                    ? kitchenProvider?.setDateFilter(val)
                    : provider?.setDateFilter(val)
              : null,
          items: ['Today', 'This Week', 'This Month', 'All']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
