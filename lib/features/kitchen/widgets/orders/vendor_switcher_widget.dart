import 'package:flutter/material.dart';

import '../../../../model/vendor_model.dart';
import '../../../../provider/kitchen_provider.dart';

class VendorSwitcherWidget extends StatelessWidget {
  final List<VendorModel> vendors;
  final KitchenProvider provider;

  const VendorSwitcherWidget({
    super.key,
    required this.vendors,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final List<VendorModel> allVendors = [
      VendorModel(id: '', name: 'ALL KITCHENS', icon: '🏪'),
      ...vendors,
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: allVendors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final vendor = allVendors[index];
          final isSelected = provider.vendorType == vendor.id;
          return GestureDetector(
            onTap: () => provider.setVendor(vendor.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : Colors.grey.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Text(vendor.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    vendor.name,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
