import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/menu_provider.dart';
import '../model/menu_item.dart';

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
    Future.microtask(
      () => Provider.of<MenuProvider>(context, listen: false).listenItems(),
    );
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 2).format(amount);
  }

  void _showItemModal([MenuItem? item]) {
    showDialog(
      context: context,
      builder: (context) => _MenuItemModal(
        item: item,
        onSave: (newItem) {
          Provider.of<MenuProvider>(context, listen: false).saveItem(newItem);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);
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
        title: const Text(
          "Menu Management",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () => _showItemModal(),
              icon: const Icon(Icons.add_circle, color: Color(0xFFFF4F18), size: 32),
            ),
          )
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Search and Filter
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                            onChanged: (value) => setState(() => searchQuery = value),
                            decoration: const InputDecoration(
                              hintText: "Search dishes...",
                              prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
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
                            icon: const Icon(Icons.filter_list, size: 18),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text("All")),
                              DropdownMenuItem(value: 'fast_food', child: Text("Tasus")),
                              DropdownMenuItem(value: 'beverages', child: Text("NESCAFÉ")),
                            ],
                            onChanged: (value) => setState(() => filterVendor = value!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content - Card Based List
                Expanded(
                  child: filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            "No items found",
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _MenuItemCard(
                              item: item,
                              formatCurrency: formatCurrency,
                              onToggle: () => provider.toggleAvailability(item),
                              onEdit: () => _showItemModal(item),
                              onDelete: () {
                                // Add delete confirmation and logic here
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final String Function(double) formatCurrency;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuItemCard({
    required this.item,
    required this.formatCurrency,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.vendorId == 'fast_food' ? Icons.fastfood : Icons.local_cafe,
                    color: const Color(0xFFFF4F18),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.vendorId == 'fast_food'
                                  ? const Color(0xFFFFF7ED)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.vendorId == 'fast_food' ? 'Tasus' : 'NESCAFÉ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: item.vendorId == 'fast_food'
                                    ? const Color(0xFFC2410C)
                                    : const Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.category.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: item.available,
                  onChanged: (_) => onToggle(),
                  activeColor: const Color(0xFF22C55E),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5, color: Color(0xFFF1F5F9)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrency(item.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemModal extends StatefulWidget {
  final MenuItem? item;
  final Function(MenuItem) onSave;

  const _MenuItemModal({this.item, required this.onSave});

  @override
  State<_MenuItemModal> createState() => _MenuItemModalState();
}

class _MenuItemModalState extends State<_MenuItemModal> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late String _vendorId;
  late bool _available;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
      text: widget.item?.price.toString() ?? '0',
    );
    _vendorId = widget.item?.vendorId ?? 'fast_food';
    _available = widget.item?.available ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item == null ? 'Add New Dish' : 'Edit Dish',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const _ModalLabel("DISH NAME"),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration("e.g. Classic Burger"),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ModalLabel("PRICE (৳)"),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("0.00"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ModalLabel("VENDOR"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _vendorId,
                            items: const [
                              DropdownMenuItem(value: 'fast_food', child: Text("Tasus")),
                              DropdownMenuItem(value: 'beverages', child: Text("NESCAFÉ")),
                            ],
                            onChanged: (v) => setState(() => _vendorId = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _available,
                  onChanged: (v) => setState(() => _available = v!),
                  activeColor: const Color(0xFFFF4F18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const Text(
                  "Available for orders",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      final newItem = MenuItem(
                        id: widget.item?.id ?? '',
                        name: _nameController.text,
                        price: double.tryParse(_priceController.text) ?? 0,
                        vendorId: _vendorId,
                        category: _vendorId,
                        available: _available,
                      );
                      widget.onSave(newItem);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4F18),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(widget.item == null ? "Create Dish" : "Save Changes"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF4F18), width: 1.5),
      ),
    );
  }
}

class _ModalLabel extends StatelessWidget {
  final String text;
  const _ModalLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 1,
        ),
      ),
    );
  }
}
