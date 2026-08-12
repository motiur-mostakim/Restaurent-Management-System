import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../provider/dashboard_provider.dart';
import 'admin_menu_screen.dart';
import 'bookings_management_screen.dart';
import 'profile_details_screen.dart';
import 'user_management_screen.dart';
import '../model/user_model.dart';

// এই ফাইলে এখন মূলত Admin এর মেইন নেভিগেশন এবং লেআউট থাকবে।
// Analytics এবং Profile কে আলাদা উইজেটে ভাগ করা হয়েছে যাতে কোড বড় না হয়।

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _AdminAnalyticsSection(),
    const AdminMenuScreen(),
    const BookingsManagementScreen(),
    const _AdminProfileSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
        NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
        NavigationDestination(icon: Icon(Icons.book_online), label: 'Bookings'),
        NavigationDestination(icon: Icon(Icons.person_pin), label: 'Profile'),
      ],
    );
  }
}

// --- ANALYTICS SECTION ---
class _AdminAnalyticsSection extends StatelessWidget {
  const _AdminAnalyticsSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Overview"),
        actions: [
          _buildFilterDropdown(provider),
        ],
      ),
      body: provider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () async => provider.listenData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatCards(provider),
                const SizedBox(height: 20),
                const Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                _buildQuickActions(context),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterDropdown(DashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: DropdownButton<String>(
        value: provider.dateFilter,
        onChanged: (val) => val != null ? provider.setDateFilter(val) : null,
        items: ['Today', 'This Week', 'This Month', 'All']
            .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      ),
    );
  }

  Widget _buildStatCards(DashboardProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _SmallStatCard(label: "Revenue", value: "৳${provider.totalSales}", icon: Icons.money, color: Colors.green),
        _SmallStatCard(label: "Orders", value: "${provider.totalOrders}", icon: Icons.receipt, color: Colors.orange),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Manage Staff"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text("Edit Menu"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMenuScreen())),
          ),
        ],
      ),
    );
  }
}

// --- PROFILE SECTION ---
class _AdminProfileSection extends StatelessWidget {
  const _AdminProfileSection();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(radius: 50, child: Icon(Icons.admin_panel_settings, size: 50)),
            const SizedBox(height: 10),
            Text(user?.email ?? "Admin User", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => FirebaseAuth.instance.signOut(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SmallStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}
