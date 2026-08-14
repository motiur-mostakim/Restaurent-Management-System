import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/order_model.dart';

class KitchenProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<OrderModel> _allOrders = [];
  String _vendorType = '';
  String _activeTab = 'live';
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'time';
  String _dateFilter = 'All';

  List<OrderModel> get orders {
    List<OrderModel> filtered = _allOrders.where((order) {
      if (!_isDateInRange(order.createdAt)) return false;

      List<String> statuses = _activeTab == 'live'
          ? ['pending', 'preparing', 'ready']
          : ['delivered'];

      bool matchesTab = statuses.contains(order.status);
      if (!matchesTab) return false;

      if (_searchQuery.isNotEmpty) {
        bool matchesSearch =
            order.tableNumber.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            order.id.toLowerCase().contains(_searchQuery.toLowerCase());
        if (!matchesSearch) return false;
      }

      return true;
    }).toList();

    if (_sortBy == 'table') {
      filtered.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
    } else {
      if (_activeTab == 'live') {
        filtered.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        );
      } else {
        filtered.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
      }
    }
    return filtered;
  }

  int get pendingCount => _allOrders
      .where((o) => o.status == 'pending' && _isDateInRange(o.createdAt))
      .length;

  int get readyCount => _allOrders
      .where((o) => o.status == 'ready' && _isDateInRange(o.createdAt))
      .length;

  int get completedCount => _allOrders
      .where((o) => o.status == 'delivered' && _isDateInRange(o.createdAt))
      .length;

  int get activeCount => _allOrders
      .where(
        (o) =>
            ['pending', 'preparing', 'ready'].contains(o.status) &&
            _isDateInRange(o.createdAt),
      )
      .length;

  double get totalSales {
    double sales = 0;
    for (var order in _allOrders) {
      if (order.status == 'delivered' && _isDateInRange(order.createdAt)) {
        for (var item in order.items) {
          bool isMyVendor = _vendorType.isEmpty || item.vendorId == _vendorType;
          if (isMyVendor && item.status == 'delivered') {
            sales += item.price * item.quantity;
          }
        }
      }
    }
    return sales;
  }

  String get vendorType => _vendorType;

  String get activeTab => _activeTab;

  bool get isLoading => _isLoading;

  String get searchQuery => _searchQuery;

  String get sortBy => _sortBy;

  String get dateFilter => _dateFilter;

  void setDateFilter(String filter) {
    _dateFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setVendor(String vendorId) {
    if (_vendorType != vendorId) {
      _vendorType = vendorId;
      listenOrders();
      notifyListeners();
    }
  }

  set activeTab(String value) {
    _activeTab = value;
    notifyListeners();
  }

  void listenOrders() {
    _isLoading = true;
    notifyListeners();

    _db.collection('orders').snapshots().listen((snapshot) {
      List<OrderModel> orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      _allOrders = orders.where((order) {
        return order.items.any((item) {
          return _vendorType.isEmpty || item.vendorId == _vendorType;
        });
      }).toList();

      _isLoading = false;
      notifyListeners();
    });
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

  void calculateTotalSales() {}

  Future<void> updateItemStatus(
    String orderId,
    int itemIndex,
    String newStatus,
  ) async {
    final orderIdx = _allOrders.indexWhere((o) => o.id == orderId);
    if (orderIdx == -1) return;

    final order = _allOrders[orderIdx];
    List<Map<String, dynamic>> updatedItems = order.items
        .map((item) => item.toMap())
        .toList();
    updatedItems[itemIndex]['status'] = newStatus;

    bool allReady = updatedItems.every(
      (i) => i['status'] == 'ready' || i['status'] == 'delivered',
    );

    await _db.collection('orders').doc(orderId).update({
      'items': updatedItems,
      'status': allReady ? 'ready' : 'preparing',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
