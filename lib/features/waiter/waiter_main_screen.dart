import 'package:flutter/material.dart';
import '/features/waiter/waiter_dashboard_screen.dart';
import '/features/waiter/waiter_new_order_screen.dart';
import '/features/waiter/waiter_profile_screen.dart';
import '/features/waiter/waiter_orders_screen.dart';

class WaiterMainScreen extends StatefulWidget {
  const WaiterMainScreen({super.key});

  @override
  State<WaiterMainScreen> createState() => _WaiterMainScreenState();
}

class _WaiterMainScreenState extends State<WaiterMainScreen> {
  int _selectedIndex = 0;

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      WaiterDashboardScreen(onNavigate: _onNavigate),
      const WaiterNewOrderScreen(),
      const WaiterOrdersScreen(isTabView: true),
      const WaiterProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
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
            Icons.dashboard,
            color: Color(_selectedIndex == 0 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.add_shopping_cart,
            color: Color(_selectedIndex == 1 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'New Order',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.track_changes,
            color: Color(_selectedIndex == 2 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Tracking',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person,
            color: Color(_selectedIndex == 3 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
