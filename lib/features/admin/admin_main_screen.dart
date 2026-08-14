import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_profile_screen.dart';
import 'bookings_management_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const AdminMenuScreen(),
    const BookingsManagementScreen(),
    const AdminProfileSection(),
  ];

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
            Icons.restaurant_menu,
            color: Color(_selectedIndex == 1 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Menu',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.book_online,
            color: Color(_selectedIndex == 2 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person_pin,
            color: Color(_selectedIndex == 3 ? 0xFFFFFFFF : 0xFF1C1C1C),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
