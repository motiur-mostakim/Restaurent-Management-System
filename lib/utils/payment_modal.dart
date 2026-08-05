import 'package:flutter/material.dart';
import '../model/order_model.dart';
import 'payment_option.dart';

class PaymentModal extends StatefulWidget {
  final OrderModel order;
  final Function(String) onComplete;

  const PaymentModal({super.key, required this.order, required this.onComplete});

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  String step = 'method';
  String? selectedMethod;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 460,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step == 'method' ? "Payment Method" : "Order Summary",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                      ),
                      Text(
                        "Table ${widget.order.tableNumber} • ৳${widget.order.totalAmount.toInt()}",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, size: 22, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
              child: Column(
                children: [
                  if (step == 'method') ...[
                    PaymentOption(
                      icon: Icons.payments_rounded,
                      label: "Cash Collection",
                      subtitle: "Collect cash at the table",
                      isSelected: selectedMethod == 'cash',
                      onTap: () => setState(() => selectedMethod = 'cash'),
                    ),
                    const SizedBox(height: 16),
                    PaymentOption(
                      icon: Icons.credit_card_rounded,
                      label: "Card / POS",
                      subtitle: "Visa, Mastercard, etc.",
                      isSelected: selectedMethod == 'card',
                      onTap: () => setState(() => selectedMethod = 'card'),
                    ),
                    const SizedBox(height: 16),
                    PaymentOption(
                      icon: Icons.qr_code_scanner_rounded,
                      label: "Mobile Wallet",
                      subtitle: "bKash, Nagad, etc.",
                      isSelected: selectedMethod == 'mobile',
                      onTap: () => setState(() => selectedMethod = 'mobile'),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: selectedMethod == null
                          ? null
                          : () => setState(() => step = 'receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4F18),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Review Receipt", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          ...widget.order.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${item.quantity}x ${item.name}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                                  Text("৳${(item.price * item.quantity).toInt()}", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 32, thickness: 0.1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Received", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              Text(
                                "৳${widget.order.totalAmount.toInt()}",
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFFF4F18), fontSize: 28, letterSpacing: -1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () async {
                              setState(() => isProcessing = true);
                              await widget.onComplete(selectedMethod!);
                              if (mounted) Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: isProcessing
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text("Send to Kitchen", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() => step = 'method'),
                      child: const Text("Change Payment Method", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w800)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
