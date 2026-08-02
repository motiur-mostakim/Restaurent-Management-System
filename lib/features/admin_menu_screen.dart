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
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 48,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => searchQuery = value),
                          decoration: const InputDecoration(
                            hintText: "Search dishes...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 6
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                       Container(
                          height: 48,
                          width: 130,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: filterVendor,
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text("All Vendors"),
                                ),
                                DropdownMenuItem(
                                  value: 'fast_food',
                                  child: Text("Tasus"),
                                ),
                                DropdownMenuItem(
                                  value: 'beverages',
                                  child: Text("NESCAFÉ"),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => filterVendor = value!),
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _showItemModal(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 48),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        child: const Text("Add Item"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Menu Table
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 700, // table minimum width
                        child: Column(
                          children: [
                            _TableHeader(),
                            ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return _MenuTableRow(
                                  item: item,
                                  formatCurrency: formatCurrency,
                                  onToggle: () => provider.toggleAvailability(item),
                                  onEdit: () => _showItemModal(item),
                                  onDelete: () {},
                                );
                              },
                              separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.2,),
                            ),
                          ],
                        ),
                      ),
                    )
                  ),
                ],
              ),
            ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderText("DISH NAME")),
          Expanded(flex: 2, child: _HeaderText("VENDOR")),
          Expanded(flex: 2, child: _HeaderText("CATEGORY")),
          Expanded(flex: 2, child: _HeaderText("PRICE")),
          Expanded(flex: 2, child: _HeaderText("STATUS")),
          Expanded(
            flex: 1,
            child: _HeaderText("ACTIONS", textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const _HeaderText(this.text, {this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 1,
      ),
    );
  }
}

class _MenuTableRow extends StatelessWidget {
  final MenuItem item;
  final String Function(double) formatCurrency;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuTableRow({
    required this.item,
    required this.formatCurrency,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.vendorId == 'fast_food'
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
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
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.category.replaceAll('_', ' '),
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatCurrency(item.price),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 32,
                    height: 16,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: item.available
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: item.available
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
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
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item == null ? 'Add New Dish' : 'Edit Dish',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const _ModalLabel("DISH NAME"),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration("e.g. Classic Burger"),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ModalLabel("PRICE (\$)"),
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
                              DropdownMenuItem(
                                value: 'fast_food',
                                child: Text("Tasus"),
                              ),
                              DropdownMenuItem(
                                value: 'beverages',
                                child: Text("NESCAFÉ"),
                              ),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _available,
                  onChanged: (v) => setState(() => _available = v!),
                  activeColor: const Color(0xFFFF4F18),
                ),
                const Text(
                  "Available for orders",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        // Using vendorId as category for simplicity
                        available: _available,
                      );
                      widget.onSave(newItem);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4F18),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.item == null ? "Create Dish" : "Save Changes",
                    ),
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
