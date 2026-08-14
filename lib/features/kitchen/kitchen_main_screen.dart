import 'package:flutter/material.dart';
import '/features/kitchen/kitchen_profile_screen.dart';
import 'kitchen_dashboard_screen.dart';
import 'kitchen_order_screen.dart';
import 'kitchen_menu_screen.dart';

class KitchenMainScreen extends StatefulWidget {
  const KitchenMainScreen({super.key});

  @override
  State<KitchenMainScreen> createState() => _KitchenMainScreenState();
}

class _KitchenMainScreenState extends State<KitchenMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const KitchenDashboardScreen(),
    const KitchenOrderScreen(),
    const KitchenMenuScreen(showAppBar: true),
    const KitchenProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      backgroundColor: Colors.white,
      selectedIndex: _selectedIndex,
      indicatorColor: const Color(0xFFFF4F18),
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      destinations: [
        NavigationDestination(
          icon: Icon(
            _selectedIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined,
            color: Color(_selectedIndex == 0 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(
            _selectedIndex == 1 ? Icons.restaurant : Icons.restaurant_outlined,
            color: Color(_selectedIndex == 1 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(
            _selectedIndex == 2 ? Icons.inventory_2 : Icons.inventory_2_outlined,
            color: Color(_selectedIndex == 2 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Inventory',
        ),
        NavigationDestination(
          icon: Icon(
            _selectedIndex == 3 ? Icons.person : Icons.person_outline,
            color: Color(_selectedIndex == 3 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
