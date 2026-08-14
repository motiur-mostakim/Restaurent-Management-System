import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/order_model.dart';
import '../../provider/waiterProvider.dart';
import 'widgets/payment_method_dialog_widget.dart';
import 'widgets/cart_item_title_widget.dart';
import 'widgets/category_button_widget.dart';
import 'widgets/order_input_card_widget.dart';
import 'widgets/product_item_card_widget.dart';

class WaiterNewOrderScreen extends StatefulWidget {
  const WaiterNewOrderScreen({super.key});

  @override
  State<WaiterNewOrderScreen> createState() => _WaiterNewOrderScreenState();
}

class _WaiterNewOrderScreenState extends State<WaiterNewOrderScreen> {
  final Color primaryColor = const Color(0xFFFF4F18);
  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WaiterProvider>(context, listen: false);
      provider.listenMenu();
      provider.listenVendors();
    });
  }

  @override
  void dispose() {
    _tableController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '৳', decimalDigits: 0).format(amount);
  }

  void _showPaymentAndConfirm(WaiterProvider provider) {
    if (_tableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter table number")),
      );
      return;
    }

    if (provider.cart.isEmpty) return;

    final tempOrder = OrderModel(
      id: '',
      waiterId: '',
      tableNumber: _tableController.text,
      status: 'pending',
      totalAmount: provider.total,
      createdAt: DateTime.now(),
      items: provider.cart
          .map(
            (item) => OrderItem(
              name: item.name,
              vendorId: item.vendorId,
              price: item.price,
              quantity: item.quantity,
              status: 'pending',
              image: item.image,
            ),
          )
          .toList(),
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => PaymentMethodDialogWidget(
        order: tempOrder,
        onComplete: (paymentMethod) async {
          await provider.placeOrder(context, paymentMethod: paymentMethod);
          if (mounted) {
            _tableController.clear();
            _notesController.clear();
          }
        },
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutQuart)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaiterProvider>(context);
    final filteredItems = provider.filteredMenuItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Create New Order",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Order Summary",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      provider.cart.isEmpty
                                          ? "No items selected"
                                          : "${provider.cart.length} items in selection",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: OrderInputCardWidget(
                                  label: "TABLE",
                                  hint: "e.g. T-05",
                                  controller: _tableController,
                                  onChanged: (v) => provider.tableNumber = v,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: OrderInputCardWidget(
                                  label: "NOTES",
                                  hint: "Any instructions?",
                                  controller: _notesController,
                                  onChanged: (v) => provider.specialNotes = v,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (provider.cart.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 40,
                              color: Colors.grey[200],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Selection is empty",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        itemCount: provider.cart.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = provider.cart[index];
                          return CartItemTitleWidget(
                            item: item,
                            onUpdate: (delta) =>
                                provider.updateQuantity(item.id, delta),
                            onRemove: () => provider.removeFromCart(item.id),
                            formatCurrency: formatCurrency,
                          );
                        },
                      ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "TOTAL",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                formatCurrency(provider.total),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed:
                                (provider.cart.isEmpty || provider.isSubmitting)
                                ? null
                                : () => _showPaymentAndConfirm(provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: provider.isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Confirm Order",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Explore Menu",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          CategoryButtonWidget(
                            label: "All Items",
                            isSelected: provider.activeVendor == 'all',
                            onTap: () => provider.activeVendor = 'all',
                          ),
                          const SizedBox(width: 10),
                          ...provider.vendors.map((vendor) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: CategoryButtonWidget(
                                label: "${vendor.icon} ${vendor.name}",
                                isSelected: provider.activeVendor == vendor.id,
                                onTap: () => provider.activeVendor = vendor.id,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    filteredItems.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(60.0),
                              child: Text("No items available"),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                ),
                            padding: EdgeInsets.zero,
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              String vendorName = "";
                              try {
                                vendorName = provider.vendors
                                    .firstWhere((v) => v.id == item.vendorId)
                                    .name;
                              } catch (_) {}

                              return ProductItemCardWidget(
                                item: item,
                                vendorName: vendorName,
                                onAdd: () => provider.addToCart(item),
                                formatCurrency: formatCurrency,
                              );
                            },
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
