import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/kds_provider.dart';
import '../provider/waiterProvider.dart';
import '../model/order_model.dart';
import '../model/vendor_model.dart';
import 'kitchen_menu_screen.dart';

class KdsScreen extends StatefulWidget {
  const KdsScreen({super.key});

  @override
  State<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends State<KdsScreen> {
  final Color primaryColor = const Color(0xFFFF4F18);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final kdsProvider = Provider.of<KdsProvider>(context, listen: false);
      final waiterProvider = Provider.of<WaiterProvider>(context, listen: false);
      
      waiterProvider.listenVendors();
      if (kdsProvider.vendorType.isEmpty && waiterProvider.vendors.isNotEmpty) {
        kdsProvider.setVendor(waiterProvider.vendors.first.id);
      }
      
      kdsProvider.listenOrders();
      kdsProvider.calculateTotalSales();
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KdsProvider>(context);
    final waiterProvider = Provider.of<WaiterProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final currentVendor = waiterProvider.vendors.firstWhere(
      (v) => v.id == provider.vendorType,
      orElse: () => VendorModel(id: provider.vendorType, name: 'Select Vendor', icon: '🍴'),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Kitchen Display: ${currentVendor.name}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.kitchen_outlined, color: Colors.white, size: 48),
                    SizedBox(height: 12),
                    Text(
                      "Kitchen Panel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text("Order Display"),
              selected: true,
              selectedColor: primaryColor,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text("Kitchen Menu / Inventory"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KitchenMenuScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () => FirebaseAuth.instance.signOut(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Stats & Tabs
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: [
                  Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      _TabSwitcher(
                        activeTab: provider.activeTab,
                        onChanged: (val) => provider.activeTab = val,
                      ),
                      if (waiterProvider.vendors.isNotEmpty)
                        _VendorSwitcher(
                          vendors: waiterProvider.vendors,
                          activeVendor: provider.vendorType,
                          onChanged: (val) => provider.setVendor(val),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children: [
                      _HeaderStat(
                        label: "TOTAL SALES",
                        value: formatCurrency(provider.totalSales),
                        valueColor: primaryColor,
                      ),
                      _HeaderStat(
                        label: provider.activeTab == 'live'
                            ? 'LIVE PREP'
                            : 'HANDOVERED',
                        value: "${provider.orders.length} Orders",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Order Grid
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.orders.isEmpty)
              _EmptyState(activeTab: provider.activeTab)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 1400
                      ? 4
                      : screenWidth > 1000
                          ? 3
                          : screenWidth > 700
                              ? 2
                              : 1,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: screenWidth < 700 ? 1.2 : 0.75,
                ),
                itemCount: provider.orders.length,
                itemBuilder: (context, index) {
                  final order = provider.orders[index];
                  return _KdsOrderCard(
                    order: order,
                    vendorType: provider.vendorType,
                    onUpdateStatus: (itemIdx, newStatus) =>
                        provider.updateItemStatus(order.id, itemIdx, newStatus),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final String activeTab;
  final Function(String) onChanged;

  const _TabSwitcher({required this.activeTab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabItem(
            label: "LIVE QUEUE",
            icon: Icons.whatshot,
            isSelected: activeTab == 'live',
            activeColor: const Color(0xFFFF4F18),
            onTap: () => onChanged('live'),
          ),
          _TabItem(
            label: "HISTORY",
            icon: Icons.history,
            isSelected: activeTab == 'history',
            activeColor: const Color(0xFF1E293B),
            onTap: () => onChanged('history'),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorSwitcher extends StatelessWidget {
  final List<VendorModel> vendors;
  final String activeVendor;
  final Function(String) onChanged;

  const _VendorSwitcher({
    required this.vendors,
    required this.activeVendor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: vendors.map((vendor) {
          return _VendorItem(
            label: vendor.name.toUpperCase(),
            isSelected: activeVendor == vendor.id,
            onTap: () => onChanged(vendor.id),
          );
        }).toList(),
      ),
    );
  }
}

class _VendorItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VendorItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? const Color(0xFF1E293B)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _HeaderStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _KdsOrderCard extends StatelessWidget {
  final OrderModel order;
  final String vendorType;
  final Function(int, String) onUpdateStatus;

  const _KdsOrderCard({
    required this.order,
    required this.vendorType,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final waitTime = DateTime.now().difference(order.createdAt).inMinutes;
    final vendorItems = order.items
        .where((i) => i.vendorId == vendorType)
        .toList();
    final allReady = vendorItems.every(
      (i) => i.status == 'ready' || i.status == 'delivered',
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: const Color(0xFFFF4F18)),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "TABLE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        order.tableNumber,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "WAIT TIME",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          "${waitTime}m",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (order.notes != null && order.notes!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFFF7ED),
              child: Text(
                "\"${order.notes}\"",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF9A3412),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vendorItems.length,
              itemBuilder: (context, index) {
                final item = vendorItems[index];
                final originalIdx = order.items.indexOf(item);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        item.status == 'ready' ? Icons.check_circle : Icons.whatshot,
                        size: 16,
                        color: item.status == 'ready' ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "x${item.quantity} ${item.name}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      if (item.status != 'ready' && order.status != 'delivered')
                        IconButton(
                          onPressed: () => onUpdateStatus(
                            originalIdx,
                            item.status == 'pending' ? 'preparing' : 'ready',
                          ),
                          icon: const Icon(Icons.arrow_forward),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: _BottomStatus(status: order.status, allReady: allReady),
          ),
        ],
      ),
    );
  }
}

class _BottomStatus extends StatelessWidget {
  final String status;
  final bool allReady;

  const _BottomStatus({required this.status, required this.allReady});

  @override
  Widget build(BuildContext context) {
    if (status == 'delivered') {
      return const Center(child: Text("Handovered", style: TextStyle(fontWeight: FontWeight.bold)));
    }
    if (allReady) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text("Order Ready", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      );
    }
    return const Center(child: Text("In Progress", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)));
  }
}

class _EmptyState extends StatelessWidget {
  final String activeTab;

  const _EmptyState({required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          children: [
            Icon(activeTab == 'live' ? Icons.restaurant : Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(activeTab == 'live' ? "Kitchen is clear!" : "No history yet"),
          ],
        ),
      ),
    );
  }
}
