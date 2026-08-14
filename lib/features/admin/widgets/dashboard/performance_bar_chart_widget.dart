import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../provider/dashboard_provider.dart';
import 'vendor_status_card_widget.dart';

class PerformanceBarChartWidget extends StatelessWidget {
  final DashboardProvider provider;
  final Color primaryColor;
  final Color secondaryColor;
  final double maxRevenue;
  const PerformanceBarChartWidget({super.key, required this.provider, required this.primaryColor, required this.secondaryColor, required this.maxRevenue});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Revenue by Vendor",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 12,
                children: List.generate(provider.vendors.length, (index) {
                  final vendor = provider.vendors[index];
                  return VendorStatusCardWidget(
                    color: getVendorColor(index),
                    label: vendor.name,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxRevenue * 1.2 + 10,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        String text = '';
                        if (index >= 0 && index < provider.vendors.length) {
                          text = provider.vendors[index].name;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '৳${value.toInt()}',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(provider.vendors.length, (index) {
                  final vendor = provider.vendors[index];
                  final revenue = provider.vendorRevenues[vendor.id] ?? 0;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: revenue,
                        color: getVendorColor(index),
                        width: 30,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
