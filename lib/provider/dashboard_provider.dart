import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../model/menu_item.dart';
import '../model/booking_model.dart';
import '../model/vendor_model.dart';

class DashboardProvider with ChangeNotifier {
  double totalSales = 0;
  int totalOrders = 0;
  List<VendorModel> vendors = [];
  Map<String, double> vendorRevenues = {};
  Map<String, int> vendorOrdersCount = {};

  int activeBookings = 0;
  int totalMenuItems = 0;
  bool isLoading = true;
  String _dateFilter = 'All';
  String? _restaurantId;

  List<OrderModel> recentOrders = [];

  final FirebaseFirestore db = FirebaseFirestore.instance;

  String get dateFilter => _dateFilter;

  void setDateFilter(String filter) {
    _dateFilter = filter;
    _processOrders();
    _listenBookings();
  }

  bool _isDateInRange(DateTime date) {
    if (_dateFilter == 'All') return true;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (_dateFilter) {
      case 'Today':
        return date.isAfter(today);
      case 'This Week':
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        return date.isAfter(weekStart);
      case 'This Month':
        final monthStart = DateTime(now.year, now.month, 1);
        return date.isAfter(monthStart);
      case 'This Year':
        final yearStart = DateTime(now.year, 1, 1);
        return date.isAfter(yearStart);
      default:
        return true;
    }
  }

  Future<void> listenData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await db.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      _restaurantId = userDoc.data()?['restaurantId'];
    }

    if (_restaurantId == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    // Filter all streams by restaurantId
    db.collection('vendor')
      .where('restaurantId', isEqualTo: _restaurantId)
      .snapshots()
      .listen((vSnap) {
        vendors = vSnap.docs.map((doc) => VendorModel.fromFirestore(doc.id, doc.data())).toList();
        _processOrders();
      });

    db.collection('orders')
      .where('restaurantId', isEqualTo: _restaurantId)
      .snapshots()
      .listen((snapshot) {
        _processOrders();
      });

    _listenBookings();

    db.collection('menu_items')
      .where('restaurantId', isEqualTo: _restaurantId)
      .snapshots()
      .listen((snapshot) {
        totalMenuItems = snapshot.size;
        notifyListeners();
      });
  }

  void _listenBookings() {
    if (_restaurantId == null) return;

    db.collection('bookings')
        .where('restaurantId', isEqualTo: _restaurantId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .listen((snapshot) {
          int count = 0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final Timestamp? ts = data['startDate'] as Timestamp?;
            if (ts != null && _isDateInRange(ts.toDate())) {
              count++;
            }
          }
          activeBookings = count;
          notifyListeners();
        });
  }

  void _processOrders() async {
    if (_restaurantId == null) return;

    final orderSnap = await db.collection('orders')
        .where('restaurantId', isEqualTo: _restaurantId)
        .get();
    
    double sales = 0;
    int ordersCount = 0;
    Map<String, double> revenues = {};
    Map<String, int> counts = {};
    for (var v in vendors) {
      revenues[v.id] = 0;
      counts[v.id] = 0;
    }

    List<OrderModel> allOrders = orderSnap.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList();

    List<OrderModel> filteredOrders = [];

    for (var order in allOrders) {
      if (!_isDateInRange(order.createdAt)) continue;

      filteredOrders.add(order);
      sales += order.totalAmount;
      ordersCount++;
      
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
    totalOrders = ordersCount;
    vendorRevenues = revenues;
    vendorOrdersCount = counts;

    filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    recentOrders = filteredOrders.take(5).toList();
    
    isLoading = false;
    notifyListeners();
  }
}
