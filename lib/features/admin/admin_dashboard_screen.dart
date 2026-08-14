import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'widgets/dashboard/filter_widget.dart';
import 'widgets/dashboard/performance_bar_chart_widget.dart';
import 'widgets/dashboard/recent_order_widget_for_admin_dashboard.dart';
import 'widgets/dashboard/report_card_for_dashboard.dart';
import '../../provider/dashboard_provider.dart';
import 'widgets/dashboard/vendor_performance_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).listenData();
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 2).format(amount);
  }

  final Color primaryColor = const Color(0xFFFF4F18);
  final Color secondaryColor = const Color(0xFF1E293B);

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "Admin Insights",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          FilterWidget(
            provider: provider,
            isForKitchen: false,
            isForWaiter: false,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4F18)),
            )
          : RefreshIndicator(
              onRefresh: () async => provider.listenData(),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStatCards(provider),
                  const SizedBox(height: 24),
                  _buildSalesChart(provider),
                  const SizedBox(height: 24),
                  RecentOrderWidgetForAdminDashboard(
                    provider: provider,
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCards(DashboardProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        ReportCardForDashboard(
          label: "Total Revenue",
          value: formatCurrency(provider.totalSales),
          icon: Icons.credit_card,
        ),
        ReportCardForDashboard(
          label: "Total Orders",
          value: provider.totalOrders.toString(),
          icon: Icons.shopping_bag,
        ),
        ReportCardForDashboard(
          label: "Active Bookings",
          value: provider.activeBookings.toString(),
          icon: Icons.calendar_today,
        ),
        ReportCardForDashboard(
          label: "Avg. Order Value",
          value: formatCurrency(
            provider.totalOrders > 0
                ? provider.totalSales / provider.totalOrders
                : 0,
          ),
          icon: Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildSalesChart(DashboardProvider provider) {
    double maxRevenue = 0;
    provider.vendorRevenues.forEach((key, value) {
      if (value > maxRevenue) maxRevenue = value;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VendorPerformanceWidget(
          provider: provider,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
        const SizedBox(height: 24),
        PerformanceBarChartWidget(
          provider: provider,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          maxRevenue: maxRevenue,
        ),
      ],
    );
  }
}
