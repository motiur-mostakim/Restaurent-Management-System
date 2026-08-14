import 'package:flutter/material.dart';
import 'package:restaurant_management/provider/dashboard_provider.dart';

class FilterWidget extends StatelessWidget {
  final DashboardProvider provider;
  const FilterWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.dateFilter,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Color(0xFF64748B),
          ),
          onChanged: (val) => val != null ? provider.setDateFilter(val) : null,
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
