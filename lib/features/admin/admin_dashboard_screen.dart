import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'widgets/dashboard/filter_widget.dart';
import 'widgets/dashboard/performance_bar_chart_widget.dart';
import 'widgets/dashboard/recent_order_widget_for_admin_dashboard.dart';
import 'widgets/dashboard/report_card_for_dashboard.dart';
import '../../provider/dashboard_provider.dart';
import 'widgets/dashboard/vendor_performance_widget.dart';
import '../kitchen/widgets/dashboard/revenue_card_widget.dart';
import '../kitchen/widgets/dashboard/section_header_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "Admin Portal",
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
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4F18)),
            )
          : RefreshIndicator(
              onRefresh: () async => provider.listenData(),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                children: [
                  _buildWelcomeHeader(provider),
                  const SizedBox(height: 35),
                  SectionHeaderWidget(
                    title: "OPERATIONAL OVERVIEW",
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCards(provider),
                  const SizedBox(height: 35),
                  SectionHeaderWidget(
                    title: "FINANCIAL SUMMARY",
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  RevenueCardWidget(
                    value: formatCurrency(provider.totalSales),
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildFinancialBreakdown(provider),
                  const SizedBox(height: 35),
                  SectionHeaderWidget(
                    title: "TOP SELLING ITEMS",
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildTopSellingItems(provider),
                  const SizedBox(height: 35),
                  if (provider.vendors.isNotEmpty) ...[
                    _buildSalesChart(provider),
                    const SizedBox(height: 35),
                  ],
                  RecentOrderWidgetForAdminDashboard(
                    provider: provider,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader(DashboardProvider provider) {
    String formattedDate = DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [secondaryColor, secondaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      provider.restaurantName ?? "Restaurant Admin",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialBreakdown(DashboardProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportCardForDashboard(
                label: "Cash Revenue",
                value: formatCurrency(provider.cashSales),
                color: Colors.green,
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportCardForDashboard(
                label: "Card Revenue",
                value: formatCurrency(provider.cardSales),
                color: Colors.blue,
                icon: Icons.credit_card_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ReportCardForDashboard(
          label: "Mobile Banking (bKash/Nagad/Rocket)",
          value: formatCurrency(provider.mobileBankingSales),
          color: Colors.purple,
          icon: Icons.phonelink_ring_outlined,
        ),
      ],
    );
  }

  Widget _buildTopSellingItems(DashboardProvider provider) {
    if (provider.topSellingItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            "No sales data yet",
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.topSellingItems.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Color(0xFFF1F5F9),
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final item = provider.topSellingItems[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            leading: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item.key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${item.value} Sold",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards(DashboardProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportCardForDashboard(
                label: "Total Orders",
                value: provider.totalOrders.toString(),
                icon: Icons.shopping_bag_rounded,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportCardForDashboard(
                label: "Active Bookings",
                value: provider.activeBookings.toString(),
                icon: Icons.calendar_today_rounded,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportCardForDashboard(
                label: "Menu Items",
                value: provider.totalMenuItems.toString(),
                icon: Icons.restaurant_menu_rounded,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportCardForDashboard(
                label: "Avg. Order Value",
                value: formatCurrency(
                  provider.totalOrders > 0
                      ? provider.totalSales / provider.totalOrders
                      : 0,
                ),
                icon: Icons.trending_up_rounded,
                color: Colors.pink,
              ),
            ),
          ],
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
