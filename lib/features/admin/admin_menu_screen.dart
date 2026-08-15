import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/features/admin/widgets/menu/menu_item_card_widget.dart';
import 'widgets/menu/menu_item_model_widget.dart';
import '../../model/menu_item.dart';
import '../../provider/menu_provider.dart';
import '../../provider/dashboard_provider.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  String searchQuery = '';
  String filterVendor = 'all';
  final Color primaryColor = const Color(0xFFFF4F18);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MenuProvider>(context, listen: false).listenItems();
      Provider.of<DashboardProvider>(context, listen: false).listenData();
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 2).format(amount);
  }

  void _showItemModal([MenuItem? item]) {
    showDialog(
      context: context,
      builder: (context) => MenuItemModelWidget(
        item: item,
        onSave: (newItem) {
          Provider.of<MenuProvider>(context, listen: false).saveItem(newItem);
        },
        onDelete: item == null ? null : () => _confirmDelete(item),
      ),
    );
  }

  void _confirmDelete(MenuItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item"),
        content: Text("Are you sure you want to delete '${item.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<MenuProvider>(
                context,
                listen: false,
              ).deleteItem(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted successfully')),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    
    final filteredItems = provider.items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesVendor =
          filterVendor == 'all' || item.vendorId == filterVendor;
      return matchesSearch && matchesVendor;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "Menu Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () => _showItemModal(),
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFFFF4F18),
                size: 32,
              ),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => searchQuery = value),
                            decoration: const InputDecoration(
                              hintText: "Search dishes...",
                              prefixIcon: Icon(
                                Icons.search,
                                size: 20,
                                color: Color(0xFF64748B),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (dashboardProvider.vendors.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: filterVendor,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Color(0xFF64748B),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'all',
                                  child: Text("All Vendors"),
                                ),
                                ...dashboardProvider.vendors.map((v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Text(v.name),
                                )),
                              ],
                              onChanged: (value) =>
                                  setState(() => filterVendor = value!),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.restaurant_menu_outlined,
                                size: 80,
                                color: Color(0xFFE2E8F0),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty ? "Your menu is empty" : "No items found",
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => _showItemModal(),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text("Add First Item"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return MenuItemCardWidget(
                              item: item,
                              formatCurrency: formatCurrency,
                              onToggle: () => provider.toggleAvailability(item),
                              onEdit: () => _showItemModal(item),
                              onDelete: () => _confirmDelete(item),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
