import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../model/menu_item.dart';
import '../../model/vendor_model.dart';
import '../../provider/kds_provider.dart';
import '../../provider/menu_provider.dart';
import '../../provider/waiterProvider.dart';

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

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final kdsProvider = Provider.of<KdsProvider>(context);
    final waiterProvider = Provider.of<WaiterProvider>(context);

    final categories = menuProvider.items
        .where((item) => kdsProvider.vendorType.isEmpty || item.vendorId == kdsProvider.vendorType)
        .map((item) => item.category)
        .toSet()
        .toList();

    List<VendorModel> displayVendors = [
      VendorModel(id: '', name: 'All Kitchens', icon: '🍽️'),
      ...waiterProvider.vendors
    ];

    final currentVendor = kdsProvider.vendorType.isEmpty
        ? VendorModel(id: '', name: 'All Kitchens', icon: '🍽️')
        : waiterProvider.vendors.firstWhere(
            (v) => v.id == kdsProvider.vendorType,
            orElse: () => VendorModel(id: kdsProvider.vendorType, name: 'Kitchen', icon: '🍴'),
          );

    final vendorItems = menuProvider.items.where((item) {
      bool matchesVendor = kdsProvider.vendorType.isEmpty || item.vendorId == kdsProvider.vendorType;
      bool matchesCategory = _selectedCategory == null || item.category == _selectedCategory;
      bool matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesAvailability = _availabilityFilter == 'All' ||
          (_availabilityFilter == 'Available' && item.available) ||
          (_availabilityFilter == 'Sold Out' && !item.available);
      return matchesVendor && matchesCategory && matchesSearch && matchesAvailability;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.showAppBar ? AppBar(
        title: Text("${currentVendor.name} Inventory", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ) : null,
      body: Column(
        children: [
          // Modern Search and Filter Section
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
                // Search Bar
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
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                        suffixIcon: _searchQuery.isNotEmpty 
                            ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                
                // Vendor Selection (Horizontal Pills)
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: displayVendors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final vendor = displayVendors[index];
                      final isSelected = kdsProvider.vendorType == vendor.id;
                      return GestureDetector(
                        onTap: () {
                          kdsProvider.setVendor(vendor.id);
                          setState(() => _selectedCategory = null);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? primaryColor : const Color(0xFFE2E8F0)),
                            boxShadow: isSelected ? [
                              BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                            ] : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            vendor.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: menuProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vendorItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: vendorItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = vendorItems[index];
                          return _buildItemCard(item, menuProvider);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _availabilityFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _availabilityFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? secondaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? secondaryColor : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String cat) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = isSelected ? null : cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? primaryColor : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          cat,
          style: TextStyle(
            color: isSelected ? primaryColor : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(MenuItem item, MenuProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Enhanced Image UI
                Stack(
                  children: [
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFF8FAFC),
                        image: (item.image != null && item.image!.isNotEmpty)
                            ? DecorationImage(image: NetworkImage(item.image!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: (item.image == null || item.image!.isEmpty)
                          ? const Icon(Icons.restaurant_menu_rounded, color: Color(0xFFCBD5E1), size: 30)
                          : null,
                    ),
                    if (!item.available)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(Icons.block_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(item.price),
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom Toggle Switch
                Column(
                  children: [
                    Switch.adaptive(
                      value: item.available,
                      activeColor: primaryColor,
                      onChanged: (val) => provider.toggleAvailability(item),
                    ),
                    Text(
                      item.available ? "AVAILABLE" : "SOLD OUT",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: item.available ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
            child: Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          const Text("No Items Found", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text("Try adjusting your filters or search query", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
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
