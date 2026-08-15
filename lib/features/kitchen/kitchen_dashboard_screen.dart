import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../admin/widgets/dashboard/filter_widget.dart';
import 'widgets/dashboard/kitchen_dashboard_inventory_alert_widget.dart';
import 'widgets/dashboard/section_header_widget.dart';
import '../../provider/kitchen_provider.dart';
import '../../provider/waiterProvider.dart';
import '../../provider/menu_provider.dart';
import '../waiter/widgets/report_card_for_waiter_dashboard.dart';
import 'widgets/dashboard/live_order_card_widget.dart';
import 'widgets/dashboard/revenue_card_widget.dart' show RevenueCardWidget;

class KitchenDashboardScreen extends StatefulWidget {
  const KitchenDashboardScreen({super.key});

  @override
  State<KitchenDashboardScreen> createState() => _KitchenDashboardScreenState();
}

class _KitchenDashboardScreenState extends State<KitchenDashboardScreen> {
  final Color primaryColor = const Color(0xFFFF4F18);
  final Color surfaceColor = const Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<KitchenProvider>(context, listen: false);
      provider.activeTab = 'live';
      provider.listenOrders();
      provider.calculateTotalSales();

      Provider.of<MenuProvider>(context, listen: false).listenItems();
      Provider.of<WaiterProvider>(context, listen: false).listenVendors();
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KitchenProvider>(context);
    final waiterProvider = Provider.of<WaiterProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);

    final outOfStockCount = menuProvider.items.where((item) {
      bool matchesVendor =
          provider.vendorType.isEmpty || item.vendorId == provider.vendorType;
      return matchesVendor && !item.available;
    }).length;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        toolbarHeight: 70,
        title: const Text(
          "Kitchen Dashboard",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          FilterWidget(
            kitchenProvider: provider,
            isForKitchen: true,
            isForWaiter: false,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          provider.listenOrders();
          menuProvider.listenItems();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    analyticsWidget(provider),
                    if (outOfStockCount > 0) ...[
                      const SizedBox(height: 24),
                      KitchenDashboardInventoryAlertWidget(
                        count: outOfStockCount,
                      ),
                    ],

                    const SizedBox(height: 32),
                    SectionHeaderWidget(
                      title: "LIVE ORDERS",
                      badge: provider.orders.isNotEmpty
                          ? "${provider.orders.length} ACTIVE"
                          : null,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.orders.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.orders.length,
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: LiveOrderCardWidget(
                        order: order,
                        vendorType: provider.vendorType,
                        primaryColor: primaryColor,
                        onUpdateStatus: (itemIdx, status) => provider
                            .updateItemStatus(order.id, itemIdx, status),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget analyticsWidget(KitchenProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ReportCardForWaiterDashboard(
                title: "ACTIVE",
                value: "${provider.activeCount}",
                icon: Icons.bolt_rounded,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ReportCardForWaiterDashboard(
                title: "PENDING",
                value: "${provider.pendingCount}",
                icon: Icons.timer_outlined,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ReportCardForWaiterDashboard(
                title: "READY",
                value: "${provider.readyCount}",
                icon: Icons.check_circle_outline_rounded,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ReportCardForWaiterDashboard(
                title: "COMPLETED",
                value: "${provider.completedCount}",
                icon: Icons.done_all_rounded,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RevenueCardWidget(
          value: formatCurrency(provider.totalSales),
          color: Colors.indigoAccent,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(
            Icons.assignment_turned_in_rounded,
            size: 80,
            color: Colors.grey[200],
          ),
          const SizedBox(height: 24),
          const Text(
            "Queue Clear",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Color(0xFF94A3B8),
            ),
          ),
          const Text(
            "No pending orders found.",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
