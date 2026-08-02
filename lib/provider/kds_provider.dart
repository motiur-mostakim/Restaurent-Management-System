import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/order_model.dart';

class KdsProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<OrderModel> _orders = [];
  double _totalSales = 0;
  String _vendorType = '';
  String _activeTab = 'live';
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  double get totalSales => _totalSales;
  String get vendorType => _vendorType;
  String get activeTab => _activeTab;
  bool get isLoading => _isLoading;

  set vendorType(String value) {
    _vendorType = value;
    listenOrders();
    calculateTotalSales();
    notifyListeners();
  }

  void setVendor(String vendorId) {
    if (_vendorType != vendorId) {
      _vendorType = vendorId;
      listenOrders();
      calculateTotalSales();
      notifyListeners();
    }
  }

  set activeTab(String value) {
    _activeTab = value;
    listenOrders();
    notifyListeners();
  }

  void listenOrders() {
    if (_vendorType.isEmpty) return; // ভেন্ডর সিলেক্ট না থাকলে থামিয়ে দিবে

    _isLoading = true;
    notifyListeners();

    List<String> statuses = _activeTab == 'live' 
        ? ['pending', 'preparing', 'ready'] 
        : ['delivered'];

    _db
        .collection('orders')
        .where('status', whereIn: statuses)
        .snapshots()
        .listen((snapshot) {
      List<OrderModel> allOrders =
          snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

      _orders = allOrders.where((order) {
        return order.items.any((item) {
          bool isMyVendor = item.vendorId == _vendorType;
          if (_activeTab == 'live') return isMyVendor && item.status != 'delivered';
          return isMyVendor && item.status == 'delivered';
        });
      }).toList();

      // Sort
      if (_activeTab == 'live') {
        _orders.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Oldest first
      } else {
        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  void calculateTotalSales() {
    _db
        .collection('orders')
        .where('status', isEqualTo: 'delivered')
        .snapshots()
        .listen((snapshot) {
      double sales = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List? ?? [];
        for (var item in items) {
          if (item['vendorId'] == _vendorType && item['status'] == 'delivered') {
            sales += (item['price'] as num).toDouble() * (item['quantity'] as num).toDouble();
          }
        }
      }
      _totalSales = sales;
      notifyListeners();
    });
  }

  Future<void> updateItemStatus(String orderId, int itemIndex, String newStatus) async {
    final order = _orders.firstWhere((o) => o.id == orderId);
    
    List<Map<String, dynamic>> updatedItems = order.items.map((item) => item.toMap()).toList();
    updatedItems[itemIndex]['status'] = newStatus;

    // Check if ALL items in the entire order are ready or delivered
    bool allReady = updatedItems.every((i) => i['status'] == 'ready' || i['status'] == 'delivered');

    await _db.collection('orders').doc(orderId).update({
      'items': updatedItems,
      'status': allReady ? 'ready' : 'preparing',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
