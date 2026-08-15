import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/menu_item.dart';
import '../model/order_model.dart';
import '../model/vendor_model.dart';

class WaiterProvider with ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<MenuItem> menuItems = [];
  List<CartItem> cart = [];
  List<OrderModel> orders = [];
  List<VendorModel> vendors = [];
  String? _restaurantId;

  String _activeVendor = 'all';
  String get activeVendor => _activeVendor;
  
  set activeVendor(String value) {
    _activeVendor = value;
    notifyListeners();
  }

  String _dateFilter = 'Today';
  String get dateFilter => _dateFilter;

  void setDateFilter(String filter) {
    _dateFilter = filter;
    notifyListeners();
  }

  List<OrderModel> get filteredOrdersByDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return orders.where((order) {
      final orderDate = order.createdAt;
      final dateOnly = DateTime(orderDate.year, orderDate.month, orderDate.day);

      switch (_dateFilter) {
        case 'Today':
          return dateOnly.isAtSameMomentAs(today);
        case 'This Week':
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          return dateOnly.isAtSameMomentAs(startOfWeek) || dateOnly.isAfter(startOfWeek);
        case 'This Month':
          return orderDate.year == now.year && orderDate.month == now.month;
        case 'This Year':
          return orderDate.year == now.year;
        case 'All':
          return true;
        default:
          return true;
      }
    }).toList();
  }

  String tableNumber = '';
  String specialNotes = '';
  bool isSubmitting = false;

  List<MenuItem> get filteredMenuItems {
    if (_activeVendor == 'all') return menuItems;
    return menuItems.where((item) => item.vendorId == _activeVendor).toList();
  }

  Future<void> _fetchRestaurantId() async {
    if (_restaurantId != null) return;
    final user = auth.currentUser;
    if (user != null) {
      final doc = await db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _restaurantId = doc.data()?['restaurantId'];
      }
    }
  }

  void listenMenu() async {
    await _fetchRestaurantId();
    if (_restaurantId == null) return;

    db
        .collection('menu_items')
        .where('restaurantId', isEqualTo: _restaurantId)
        .where('available', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      menuItems = snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.id, doc.data()))
          .toList();

      notifyListeners();
    });
  }

  void listenVendors() async {
    await _fetchRestaurantId();
    if (_restaurantId == null) return;

    db.collection('vendor')
      .where('restaurantId', isEqualTo: _restaurantId)
      .snapshots()
      .listen((snapshot) {
      vendors = snapshot.docs
          .map((doc) => VendorModel.fromFirestore(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  void listenOrders() async {
    await _fetchRestaurantId();
    if (_restaurantId == null) return;
    
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    db
        .collection('orders')
        .where('restaurantId', isEqualTo: _restaurantId)
        .where('waiterId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    });
  }

  void addToCart(MenuItem item) {
    final index = cart.indexWhere((i) => i.id == item.id);

    if (index != -1) {
      cart[index].quantity++;
    } else {
      cart.add(CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        vendorId: item.vendorId,
        category: item.category,
        image: item.image,
      ));
    }

    notifyListeners();
  }

  void updateQuantity(String id, int delta) {
    final index = cart.indexWhere((i) => i.id == id);

    if (index != -1) {
      final newQty = cart[index].quantity + delta;
      if (newQty > 0) {
        cart[index].quantity = newQty;
      } else {
        cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String id) {
    cart.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  double get total =>
      cart.fold(0, (sum, item) => sum + item.price * item.quantity);

  Future<void> placeOrder(BuildContext context, {String? paymentMethod}) async {
    if (tableNumber.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter table number")));
      return;
    }

    if (cart.isEmpty) return;

    await _fetchRestaurantId();
    if (_restaurantId == null) return;

    isSubmitting = true;
    notifyListeners();

    try {
      final orderItems = cart.map((item) => OrderItem(
        name: item.name,
        vendorId: item.vendorId,
        price: item.price,
        quantity: item.quantity,
        status: 'pending',
        image: item.image,
      )).toList();

      final newOrder = OrderModel(
        id: '',
        waiterId: auth.currentUser?.uid ?? '',
        tableNumber: tableNumber,
        status: 'pending',
        totalAmount: total,
        paymentMethod: paymentMethod,
        notes: specialNotes,
        createdAt: DateTime.now(),
        items: orderItems,
      );

      final orderData = newOrder.toMap();
      orderData['createdAt'] = FieldValue.serverTimestamp();
      orderData['restaurantId'] = _restaurantId;

      await db.collection('orders').add(orderData);

      cart.clear();
      tableNumber = '';
      specialNotes = '';

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Order placed successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to place order")));
    }

    isSubmitting = false;
    notifyListeners();
  }

  Future<void> completeHandover(String orderId, String? paymentMethod) async {
    try {
      final order = orders.firstWhere((o) => o.id == orderId);
      
      for (var item in order.items) {
        item.status = 'delivered';
      }

      await db.collection('orders').doc(orderId).update({
        'status': 'delivered',
        'paymentMethod': paymentMethod ?? order.paymentMethod,
        'items': order.items.map((i) => i.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Handover error: $e");
    }
  }
}
