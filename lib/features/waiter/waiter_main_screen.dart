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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFF4F18),
          unselectedItemColor: const Color(0xFF94A3B8),
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart_outlined),
              activeIcon: Icon(Icons.add_shopping_cart_rounded),
              label: 'New Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_outlined),
              activeIcon: Icon(Icons.track_changes_rounded),
              label: 'Tracking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
