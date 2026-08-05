import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/kds_provider.dart';
import '../provider/waiterProvider.dart';
import '../model/vendor_model.dart';
import '../model/order_model.dart';
import 'kitchen_menu_screen.dart';

class KitchenDashboardScreen extends StatefulWidget {
  const KitchenDashboardScreen({super.key});

  @override
  State<KitchenDashboardScreen> createState() => _KitchenDashboardScreenState();
}

class _KitchenDashboardScreenState extends State<KitchenDashboardScreen> {
  final Color primaryColor = const Color(0xFFFF4F18);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<KdsProvider>(context, listen: false);
      // Ensure we are tracking live orders on the dashboard
      provider.activeTab = 'live';
      provider.listenOrders();
      provider.calculateTotalSales();
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KdsProvider>(context);
    final waiterProvider = Provider.of<WaiterProvider>(context);
    
    final currentVendorName = provider.vendorType.isEmpty 
        ? "All Kitchens" 
        : waiterProvider.vendors.firstWhere(
            (v) => v.id == provider.vendorType,
            orElse: () => VendorModel(id: provider.vendorType, name: 'Kitchen', icon: '🍴'),
          ).name;

    // Prepare vendors list with "All" option
    List<VendorModel> displayVendors = [
      VendorModel(id: '', name: 'All', icon: '🍽️'),
      ...waiterProvider.vendors
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Kitchen Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $currentVendorName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: "TOTAL SALES",
                    value: formatCurrency(provider.totalSales),
                    icon: Icons.monetization_on_outlined,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: "ACTIVE ORDERS",
                    value: "${provider.orders.length}",
                    icon: Icons.restaurant,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            // Vendor Switcher
            const Text(
              "Switch Kitchen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayVendors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final vendor = displayVendors[index];
                  final isSelected = provider.vendorType == vendor.id;
                  return GestureDetector(
                    onTap: () => provider.setVendor(vendor.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: isSelected ? primaryColor : const Color(0xFFE2E8F0)),
                        boxShadow: isSelected ? [
                          BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                        ] : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        vendor.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
            // Live Orders Horizontal Scroll
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Live Orders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                if (provider.orders.isNotEmpty)
                  Text(
                    "${provider.orders.length} Active",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    const Text("No active orders", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return _HorizontalOrderCard(
                      order: order,
                      vendorType: provider.vendorType,
                      primaryColor: primaryColor,
                      onUpdateStatus: (itemIdx, newStatus) =>
                          provider.updateItemStatus(order.id, itemIdx, newStatus),
                    );
                  },
                ),
              ),

            const SizedBox(height: 32),
            // Quick Actions
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.inventory_2_outlined, color: primaryColor),
              ),
              title: const Text("Kitchen Menu / Inventory", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Manage item availability"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KitchenMenuScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }
}

class _HorizontalOrderCard extends StatelessWidget {
  final OrderModel order;
  final String vendorType;
  final Color primaryColor;
  final Function(int, String) onUpdateStatus;

  const _HorizontalOrderCard({
    required this.order,
    required this.vendorType,
    required this.primaryColor,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final waitTime = DateTime.now().difference(order.createdAt).inMinutes;
    final vendorItems = vendorType.isEmpty 
        ? order.items 
        : order.items.where((i) => i.vendorId == vendorType).toList();

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TABLE ${order.tableNumber}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text("${waitTime}m", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vendorItems.length,
              itemBuilder: (context, index) {
                final item = vendorItems[index];
                final originalIdx = order.items.indexOf(item);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        item.status == 'ready' ? Icons.check_circle : Icons.whatshot,
                        size: 14,
                        color: item.status == 'ready' ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "x${item.quantity} ${item.name}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.status != 'ready' && item.status != 'delivered')
                        InkWell(
                          onTap: () => onUpdateStatus(
                            originalIdx,
                            item.status == 'pending' ? 'preparing' : 'ready',
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(4)),
                            child: const Icon(Icons.arrow_forward, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (order.notes != null && order.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                "\"${order.notes}\"",
                style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.orange),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.status.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                Text(
                   DateFormat('hh:mm a').format(order.createdAt),
                   style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
