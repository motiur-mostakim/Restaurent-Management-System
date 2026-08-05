import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../model/menu_item.dart';
import '../model/booking_model.dart';
import '../model/vendor_model.dart';

class DashboardProvider with ChangeNotifier {
  double totalSales = 0;
  int totalOrders = 0;
  
  // Dynamic vendor data
  List<VendorModel> vendors = [];
  Map<String, double> vendorRevenues = {};
  Map<String, int> vendorOrdersCount = {};

  int activeBookings = 0;
  int totalMenuItems = 0;
  bool isLoading = true;

  List<OrderModel> recentOrders = [];

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> checkAndSeed() async {
    // Seed Vendors if empty (using 'vendor' collection to match database)
    final vendorSnap = await db.collection('vendor').limit(1).get();
    if (vendorSnap.docs.isEmpty) {
      debugPrint('Seeding initial vendors...');
      final initialVendors = [
        {'id': 'fast_food', 'name': 'Tasus', 'icon': '🍔'},
        {'id': 'beverages', 'name': 'NESCAFÉ', 'icon': '☕'},
      ];
      for (var v in initialVendors) {
        await db.collection('vendor').doc(v['id'] as String).set(v);
      }
    }

    final menuSnap = await db.collection('menu_items').limit(1).get();
    if (menuSnap.docs.isEmpty) {
      debugPrint('Seeding initial data...');
      final menuItems = [
        MenuItem(
          id: '',
          name: 'Classic Cheeseburger',
          price: 12.99,
          vendorId: 'fast_food',
          category: 'fast_food',
          available: true,
        ),
        MenuItem(
          id: '',
          name: 'Crispy Chicken Wings',
          price: 9.50,
          vendorId: 'fast_food',
          category: 'fast_food',
          available: true,
        ),
        MenuItem(
          id: '',
          name: 'Truffle Fries',
          price: 6.75,
          vendorId: 'fast_food',
          category: 'fast_food',
          available: true,
        ),
        MenuItem(
          id: '',
          name: 'Caramel Macchiato',
          price: 5.25,
          vendorId: 'beverages',
          category: 'beverages',
          available: true,
        ),
        MenuItem(
          id: '',
          name: 'Fresh Tropical Juice',
          price: 4.50,
          vendorId: 'beverages',
          category: 'beverages',
          available: true,
        ),
        MenuItem(
          id: '',
          name: 'Cold Brew Coffee',
          price: 4.00,
          vendorId: 'beverages',
          category: 'beverages',
          available: true,
        ),
      ];
      for (var item in menuItems) {
        await db.collection('menu_items').add(item.toJson());
      }

      final bookings = [
        BookingModel(
          id: '',
          customerName: 'John Doe',
          customerPhone: '555-0123',
          eventType: 'Birthday Party',
          startDate: DateTime.now().add(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 1, hours: 1)),
          status: 'confirmed',
          totalPrice: 250,
        ),
      ];
      for (var booking in bookings) {
        await db.collection('bookings').add(booking.toJson());
      }
    }
  }

  void listenData() {
    checkAndSeed();

    // Listen to Vendors from 'vendor' collection
    db.collection('vendor').snapshots().listen((vSnap) {
      vendors = vSnap.docs.map((doc) => VendorModel.fromFirestore(doc.id, doc.data())).toList();
      _processOrders();
    });

    db.collection('orders').snapshots().listen((snapshot) {
      _processOrders();
    });

    db
        .collection('bookings')
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .listen((snapshot) {
          activeBookings = snapshot.size;
          notifyListeners();
        });

    db.collection('menu_items').snapshots().listen((snapshot) {
      totalMenuItems = snapshot.size;
      notifyListeners();
    });
  }

  void _processOrders() async {
    final orderSnap = await db.collection('orders').get();
    
    double sales = 0;
    Map<String, double> revenues = {};
    Map<String, int> counts = {};

    // Initialize maps for all known vendors
    for (var v in vendors) {
      revenues[v.id] = 0;
      counts[v.id] = 0;
    }

    List<OrderModel> orders = orderSnap.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList();

    for (var order in orders) {
      sales += order.totalAmount;
      Set<String> orderVendors = {};

      for (var item in order.items) {
        if (revenues.containsKey(item.vendorId)) {
          revenues[item.vendorId] = (revenues[item.vendorId] ?? 0) + (item.price * item.quantity);
          orderVendors.add(item.vendorId);
        }
      }
      for (var vId in orderVendors) {
        counts[vId] = (counts[vId] ?? 0) + 1;
      }
    }

    totalSales = sales;
    totalOrders = orderSnap.size;
    vendorRevenues = revenues;
    vendorOrdersCount = counts;

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    recentOrders = orders.take(5).toList();
    
    isLoading = false;
    notifyListeners();
  }
}
