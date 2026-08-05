import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/menu_provider.dart';
import '../model/menu_item.dart';
import '../provider/kds_provider.dart';
import '../provider/waiterProvider.dart';
import '../model/vendor_model.dart';

class KitchenMenuScreen extends StatefulWidget {
  final bool showAppBar;
  const KitchenMenuScreen({super.key, this.showAppBar = true});

  @override
  State<KitchenMenuScreen> createState() => _KitchenMenuScreenState();
}

class _KitchenMenuScreenState extends State<KitchenMenuScreen> {
  final Color primaryColor = const Color(0xFFFF4F18);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MenuProvider>(context, listen: false).listenItems();
      Provider.of<WaiterProvider>(context, listen: false).listenVendors();
    });
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final kdsProvider = Provider.of<KdsProvider>(context);
    final waiterProvider = Provider.of<WaiterProvider>(context);

    final currentVendor = waiterProvider.vendors.firstWhere(
      (v) => v.id == kdsProvider.vendorType,
      orElse: () => VendorModel(id: kdsProvider.vendorType, name: kdsProvider.vendorType.toUpperCase(), icon: '🍴'),
    );

    final vendorItems = menuProvider.items.where((item) => item.vendorId == kdsProvider.vendorType).toList();

    Widget content = menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: vendorItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = vendorItems[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFF1F5F9),
                          image: (item.image != null && item.image!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(item.image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (item.image == null || item.image!.isEmpty)
                            ? const Icon(Icons.fastfood, color: Color(0xFFCBD5E1), size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(item.price),
                              style: TextStyle(
                                  color: primaryColor, 
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.available ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.available ? "AVAILABLE" : "SOLD OUT",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: item.available
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Availability Toggle
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: item.available,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            menuProvider.toggleAvailability(item);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );

    if (!widget.showAppBar) return Scaffold(backgroundColor: const Color(0xFFF8FAFC), body: content);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "${currentVendor.name} Inventory",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: content,
    );
  }
}
