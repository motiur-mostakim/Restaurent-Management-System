import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_management/features/admin/widgets/dashboard/filter_widget.dart';

import '../../provider/waiterProvider.dart';
import 'widgets/report_card_for_waiter_dashboard.dart';
import 'widgets/waiter_report_card_status_badge.dart';

class WaiterDashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const WaiterDashboardScreen({super.key, required this.onNavigate});

  @override
  State<WaiterDashboardScreen> createState() => _WaiterDashboardScreenState();
}

class _WaiterDashboardScreenState extends State<WaiterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<WaiterProvider>(context, listen: false);
      provider.listenOrders();
      provider.listenMenu();
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaiterProvider>(context);
    final filteredOrders = provider.filteredOrdersByDate;

    int totalOrders = filteredOrders.length;
    int pendingOrders = filteredOrders
        .where((o) => o.status == 'pending')
        .length;
    int deliveredOrders = filteredOrders
        .where((o) => o.status == 'delivered')
        .length;
    int readyOrders = filteredOrders.where((o) => o.status == 'ready').length;
    double totalSell = filteredOrders
        .where((o) => o.status == 'delivered')
        .fold(0.0, (sum, o) => sum + o.totalAmount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "Waiter Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          FilterWidget(
            waiterProvider: provider,
            isForWaiter: true,
            isForKitchen: false,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.92,
              children: [
                ReportCardForWaiterDashboard(
                  title: "Ready",
                  value: readyOrders.toString(),
                  icon: Icons.restaurant_outlined,
                  color: const Color(0xFF3B82F6),
                ),
                ReportCardForWaiterDashboard(
                  title: "Pending",
                  value: pendingOrders.toString(),
                  icon: Icons.timer_outlined,
                  color: const Color(0xFFF59E0B),
                ),
                ReportCardForWaiterDashboard(
                  title: "Delivered",
                  value: deliveredOrders.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF10B981),
                ),
                ReportCardForWaiterDashboard(
                  title: "${provider.dateFilter} Order",
                  value: totalOrders.toString(),
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFF6366F1),
                ),
                ReportCardForWaiterDashboard(
                  title: "Total Sell",
                  value: formatCurrency(totalSell),
                  icon: Icons.payments_outlined,
                  color: const Color(0xFFFF4F18),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Popular Items",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onNavigate(2),
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      color: Color(0xFFFF4F18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: provider.menuItems.isEmpty
                  ? const Center(
                      child: Text(
                        "Loading items...",
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: provider.menuItems.take(8).length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final item = provider.menuItems[index];
                        return Container(
                          width: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                        image:
                                            item.image != null &&
                                                item.image!.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  item.image!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        color: const Color(0xFFF1F5F9),
                                      ),
                                      child:
                                          item.image == null ||
                                              item.image!.isEmpty
                                          ? const Center(
                                              child: Icon(
                                                Icons.fastfood_outlined,
                                                color: Color(0xFFCBD5E1),
                                                size: 40,
                                              ),
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          provider.addToCart(item);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "${item.name} added",
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              width: 160,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.add_rounded,
                                            color: Color(0xFFFF4F18),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formatCurrency(item.price),
                                        style: const TextStyle(
                                          color: Color(0xFFFF4F18),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Orders",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onNavigate(1),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Color(0xFFFF4F18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            filteredOrders.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        "No orders found",
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredOrders.take(10).length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return InkWell(
                        onTap: () => widget.onNavigate(1),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.receipt_rounded,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Table: ${order.tableNumber}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${order.items.length} items • ${DateFormat('hh:mm a').format(order.createdAt)}",
                                          style: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          formatCurrency(order.totalAmount),
                                          style: const TextStyle(
                                            color: Color(0xFFFF4F18),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              WaiterReportCardStatusBadge(status: order.status),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
