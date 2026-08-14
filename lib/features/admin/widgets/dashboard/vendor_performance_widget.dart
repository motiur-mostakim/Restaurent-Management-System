import 'package:flutter/material.dart';
import 'package:restaurant_management/features/admin/widgets/dashboard/vendor_performance_progress_widget.dart';

import '../../../../provider/dashboard_provider.dart';

class VendorPerformanceWidget extends StatelessWidget {
  final DashboardProvider provider;
  final Color primaryColor;
  final Color secondaryColor;
  const VendorPerformanceWidget({super.key, required this.provider, required this.primaryColor, required this.secondaryColor});

  @override
  Widget build(BuildContext context) {
    Color getVendorColor(int index) {
      final colors = [
        primaryColor,
        secondaryColor,
        const Color(0xFF3B82F6),
        const Color(0xFFF59E0B),
        const Color(0xFF10B981),
        const Color(0xFF8B5CF6),
      ];
      return colors[index % colors.length];
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vendor Performance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...List.generate(provider.vendors.length, (index) {
            final vendor = provider.vendors[index];
            final revenue = provider.vendorRevenues[vendor.id] ?? 0;
            return Padding(
              padding: EdgeInsets.only(bottom: index == provider.vendors.length - 1 ? 0 : 20),
              child: VendorPerformanceProgressWidget(
                name: vendor.name,
                revenue: revenue,
                total: provider.totalSales,
                icon: vendor.icon == '🍔' ? Icons.restaurant : Icons.coffee,
                color: getVendorColor(index),
              ),
            );
          }),
        ],
      ),
    );
  }
}
