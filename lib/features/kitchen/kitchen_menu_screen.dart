import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_management/features/kitchen/widgets/orders/vendor_switcher_widget.dart';

import '../../model/menu_item.dart';
import '../../model/vendor_model.dart';
import '../../provider/kitchen_provider.dart';
import '../../provider/menu_provider.dart';
import '../../provider/waiterProvider.dart';
import 'widgets/inventory/inventory_item_widget.dart';

class KitchenMenuScreen extends StatefulWidget {
  final bool showAppBar;
  final String? initialAvailabilityFilter;

  const KitchenMenuScreen({
    super.key,
    this.showAppBar = true,
    this.initialAvailabilityFilter,
  });

  @override
  State<KitchenMenuScreen> createState() => _KitchenMenuScreenState();
}

class _KitchenMenuScreenState extends State<KitchenMenuScreen> {
  final Color primaryColor = const Color(0xFFFF4F18);
  final Color secondaryColor = const Color(0xFF1E293B);
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  late String _availabilityFilter;

  @override
  void initState() {
    super.initState();
    _availabilityFilter = widget.initialAvailabilityFilter ?? 'All';
    Future.microtask(() {
      Provider.of<MenuProvider>(context, listen: false).listenItems();
      Provider.of<WaiterProvider>(context, listen: false).listenVendors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final kdsProvider = Provider.of<KitchenProvider>(context);
    final waiterProvider = Provider.of<WaiterProvider>(context);

    final vendorItems = menuProvider.items.where((item) {
      bool matchesVendor =
          kdsProvider.vendorType.isEmpty ||
          item.vendorId == kdsProvider.vendorType;
      bool matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      bool matchesSearch = item.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesAvailability =
          _availabilityFilter == 'All' ||
          (_availabilityFilter == 'Available' && item.available) ||
          (_availabilityFilter == 'Sold Out' && !item.available);
      return matchesVendor &&
          matchesCategory &&
          matchesSearch &&
          matchesAvailability;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.showAppBar
          ? AppBar(
              scrolledUnderElevation: 0,
              title: const Text(
                "Inventory",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              iconTheme: const IconThemeData(color: Colors.black),
            )
          : null,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: "Search dishes, ingredients...",
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF64748B),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: VendorSwitcherWidget(
                    vendors: waiterProvider.vendors,
                    provider: kdsProvider,
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          Expanded(
            child: menuProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vendorItems.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: vendorItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = vendorItems[index];
                      return InventoryItemWidget(
                        item: item,
                        provider: menuProvider,
                        primaryColor: primaryColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Items Found",
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try adjusting your filters or search query",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => setState(() {
              _searchQuery = '';
              _selectedCategory = null;
              _availabilityFilter = 'All';
              _searchController.clear();
            }),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Reset Filters"),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
          ),
        ],
      ),
    );
  }
}
