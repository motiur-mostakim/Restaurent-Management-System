import 'package:flutter/material.dart';

class OrderEmptyStateWidget extends StatelessWidget {
  final String activeTab;
  final bool isSearching;

  const OrderEmptyStateWidget({
    super.key,
    required this.activeTab,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : (activeTab == 'live'
                        ? Icons.restaurant_menu_rounded
                        : Icons.history_rounded),
              size: 80,
              color: const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            isSearching
                ? "No results found"
                : (activeTab == 'live'
                      ? "Everything's Clear!"
                      : "History Empty"),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              isSearching
                  ? "We couldn't find any orders matching your search query."
                  : "New orders will appear here automatically as soon as they are placed.",
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
