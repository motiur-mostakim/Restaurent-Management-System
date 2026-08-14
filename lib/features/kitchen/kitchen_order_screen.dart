import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/kitchen_provider.dart';
import '../../provider/waiterProvider.dart';
import '../../model/vendor_model.dart';
import 'widgets/orders/kitchen_display_order_card_widget.dart';
import 'widgets/orders/order_empty_state_widget.dart' show OrderEmptyStateWidget;
import 'widgets/orders/vendor_switcher_widget.dart' show VendorSwitcherWidget;

class KitchenOrderScreen extends StatefulWidget {
  const KitchenOrderScreen({super.key});

  @override
  State<KitchenOrderScreen> createState() => _KitchenOrderScreenState();
}

class _KitchenOrderScreenState extends State<KitchenOrderScreen> {
  final Color primaryColor = const Color(0xFFFF4F18);
  final Color secondaryColor = const Color(0xFF0F172A);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final kdsProvider = Provider.of<KitchenProvider>(context, listen: false);
      final waiterProvider = Provider.of<WaiterProvider>(
        context,
        listen: false,
      );

      waiterProvider.listenVendors();
      kdsProvider.setVendor('');
      kdsProvider.listenOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KitchenProvider>(context);
    final waiterProvider = Provider.of<WaiterProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final currentVendor = provider.vendorType.isEmpty
        ? VendorModel(id: '', name: 'All Kitchens', icon: '🏪')
        : waiterProvider.vendors.firstWhere(
            (v) => v.id == provider.vendorType,
            orElse: () => VendorModel(
              id: provider.vendorType,
              name: 'Kitchen',
              icon: '🍴',
            ),
          );

    int crossAxisCount = screenWidth > 1400
        ? 4
        : screenWidth > 1000
        ? 3
        : screenWidth > 600
        ? 2
        : 1;
    double horizontalPadding = 24.0;
    double gap = 24.0;
    double cardWidth =
        (screenWidth - (horizontalPadding * 2) - (gap * (crossAxisCount - 1))) /
        crossAxisCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 90,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    currentVendor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.green, blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          _buildActionStat(
            context,
            label: "ACTIVE ORDERS",
            value: "${provider.activeCount}",
            color: primaryColor,
            icon: Icons.local_fire_department_rounded,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusDropdown(provider),
                VendorSwitcherWidget(
                  vendors: waiterProvider.vendors,
                  provider: provider,
                ),
              ],
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => provider.listenOrders(),
                    color: primaryColor,
                    child: provider.orders.isEmpty
                        ? OrderEmptyStateWidget(
                            activeTab: provider.activeTab,
                            isSearching: provider.searchQuery.isNotEmpty,
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: provider.orders.map((order) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: KitchenDisplayOrderCardWidget(
                                      order: order,
                                      vendorType: provider.vendorType,
                                      onUpdateStatus: (itemIdx, newStatus) =>
                                          provider.updateItemStatus(
                                            order.id,
                                            itemIdx,
                                            newStatus,
                                          ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionStat(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: color.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(KitchenProvider provider) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.activeTab,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Color(0xFF64748B),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
          onChanged: (val) => provider.activeTab = val!,
          items: const [
            DropdownMenuItem(value: 'live', child: Text("Status: Live")),
            DropdownMenuItem(
              value: 'history',
              child: Text("Status: Completed"),
            ),
          ],
        ),
      ),
    );
  }
}
