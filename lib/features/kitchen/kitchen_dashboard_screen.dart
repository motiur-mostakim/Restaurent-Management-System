import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/kds_provider.dart';
import '../../provider/waiterProvider.dart';
import '../../provider/menu_provider.dart';
import '../../model/vendor_model.dart';
import '../../model/order_model.dart';
import 'kitchen_menu_screen.dart';

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
      final provider = Provider.of<KdsProvider>(context, listen: false);
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
    final provider = Provider.of<KdsProvider>(context);
    final waiterProvider = Provider.of<WaiterProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    
    final currentVendorName = provider.vendorType.isEmpty 
        ? "Central Kitchen" 
        : waiterProvider.vendors.firstWhere(
            (v) => v.id == provider.vendorType,
            orElse: () => VendorModel(id: provider.vendorType, name: 'Kitchen', icon: '🍴'),
          ).name;

    final outOfStockCount = menuProvider.items.where((item) {
      bool matchesVendor = provider.vendorType.isEmpty || item.vendorId == provider.vendorType;
      return matchesVendor && !item.available;
    }).length;

    List<VendorModel> displayVendors = [
      VendorModel(id: '', name: 'All Stations', icon: '🏢'),
      ...waiterProvider.vendors
    ];

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentVendorName.toUpperCase(),
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.2),
            ),
            const Text(
              "Kitchen Dashboard",
              style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 22),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: provider.dateFilter,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.black54),
                style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 14),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    provider.setDateFilter(newValue);
                  }
                },
                items: <String>['Today', 'This Week', 'This Month', 'This Year', 'All']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F172A), size: 26),
            onPressed: () {
              provider.listenOrders();
              menuProvider.listenItems();
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Performance Stats Grid (2 per row) - Bigger Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: "ACTIVE",
                          value: "${provider.activeCount}",
                          icon: Icons.bolt_rounded,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: "PENDING",
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
                        child: _StatCard(
                          label: "READY",
                          value: "${provider.readyCount}",
                          icon: Icons.check_circle_outline_rounded,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: "COMPLETED",
                          value: "${provider.completedCount}",
                          icon: Icons.done_all_rounded,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _RevenueBanner(
                    value: formatCurrency(provider.totalSales),
                    color: Colors.indigoAccent,
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader("OPERATIONAL STATIONS", null),
                  const SizedBox(height: 16),
                  _buildVendorSwitcher(displayVendors, provider),
                  
                  if (outOfStockCount > 0) ...[
                    const SizedBox(height: 24),
                    _buildInventoryAlert(context, outOfStockCount),
                  ],
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    "LIVE ORDERS QUEUE", 
                    provider.orders.isNotEmpty ? "${provider.orders.length} ACTIVE" : null
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          if (provider.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (provider.orders.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = provider.orders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _DetailedOrderCard(
                        order: order,
                        vendorType: provider.vendorType,
                        primaryColor: primaryColor,
                        onUpdateStatus: (itemIdx, status) => 
                            provider.updateItemStatus(order.id, itemIdx, status),
                      ),
                    );
                  },
                  childCount: provider.orders.length,
                ),
              ),
            ),
            
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? badge) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 0.5)),
        if (badge != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(badge, style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }

  Widget _buildVendorSwitcher(List<VendorModel> vendors, KdsProvider provider) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: vendors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          final isSelected = provider.vendorType == vendor.id;
          return GestureDetector(
            onTap: () => provider.setVendor(vendor.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : [],
                border: Border.all(color: isSelected ? const Color(0xFF0F172A) : Colors.grey.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Text(vendor.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    vendor.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryAlert(BuildContext context, int count) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => KitchenMenuScreen(initialAvailabilityFilter: 'Sold Out'))),
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
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Inventory Alert", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF7F1D1D), fontSize: 16)),
                  Text("$count items out of stock. Update kitchen menu.", style: TextStyle(color: Colors.red[700], fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.red[900]),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(Icons.assignment_turned_in_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 24),
          const Text("Queue Clear", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF94A3B8))),
          const Text("No pending orders found.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label, 
    required this.value, 
    required this.icon, 
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label, 
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

class _RevenueBanner extends StatelessWidget {
  final String value;
  final Color color;

  const _RevenueBanner({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: color, size: 28),
              const SizedBox(width: 16),
              Text("PERIOD REVENUE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class _DetailedOrderCard extends StatelessWidget {
  final OrderModel order;
  final String vendorType;
  final Color primaryColor;
  final Function(int, String) onUpdateStatus;

  const _DetailedOrderCard({
    required this.order,
    required this.vendorType,
    required this.primaryColor,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final waitTime = DateTime.now().difference(order.createdAt).inMinutes;
    final vendorItems = order.items.where((i) => i.vendorId == vendorType || vendorType.isEmpty).toList();
    final isUrgent = waitTime > 15 && order.status != 'delivered';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: isUrgent ? Colors.red.withOpacity(0.3) : Colors.transparent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text("${order.tableNumber}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF1E293B))),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Table ${order.tableNumber}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      Text("#${order.id.substring(order.id.length - 6).toUpperCase()}", style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red[50] : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_rounded, size: 16, color: isUrgent ? Colors.red : Colors.green[700]),
                      const SizedBox(width: 6),
                      Text("${waitTime}m", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isUrgent ? Colors.red : Colors.green[700])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 24, endIndent: 24),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vendorItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final item = vendorItems[idx];
                final actualIndex = order.items.indexOf(item);
                final isItemReady = item.status == 'ready' || item.status == 'delivered';

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Text("${item.quantity}x", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: isItemReady ? TextDecoration.lineThrough : null,
                          color: isItemReady ? Colors.grey : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    _StatusButton(
                      status: item.status,
                      onToggle: () {
                        final newStatus = item.status == 'ready' ? 'pending' : 'ready';
                        onUpdateStatus(actualIndex, newStatus);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          if (order.notes != null && order.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber.withOpacity(0.2))),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber[900]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: TextStyle(fontSize: 13, color: Colors.amber[900], fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String status;
  final VoidCallback onToggle;

  const _StatusButton({required this.status, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isReady = status == 'ready' || status == 'delivered';
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isReady ? const Color(0xFF22C55E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isReady ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isReady) const Icon(Icons.check_rounded, color: Colors.white, size: 16),
            if (isReady) const SizedBox(width: 6),
            Text(
              isReady ? "READY" : "MARK READY",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isReady ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
