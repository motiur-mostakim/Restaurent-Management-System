import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/menu_item.dart';
import '../model/order_model.dart';

class WaiterProvider with ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<MenuItem> menuItems = [];
  List<CartItem> cart = [];
  List<OrderModel> orders = [];

  String activeVendor = 'all';
  String tableNumber = '';
  String specialNotes = '';
  bool isSubmitting = false;

  /// 🔥 Load Menu (Realtime like onSnapshot)
  void listenMenu() {
    db
        .collection('menu_items')
        .where('available', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      menuItems = snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.id, doc.data()))
          .toList();

      notifyListeners();
    });
  }

  /// 📋 Load Orders (Realtime)
  void listenOrders() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    db
        .collection('orders')
        .where('waiterId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      // Sort by creation time descending
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    });
  }

  /// ➕ Add to Cart
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
      ));
    }

    notifyListeners();
  }

  /// 🔁 Update Quantity
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

  /// ❌ Remove
  void removeFromCart(String id) {
    cart.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  /// 💰 Total
  double get total =>
      cart.fold(0, (sum, item) => sum + item.price * item.quantity);

  /// 📤 Place Order
  Future<void> placeOrder(BuildContext context) async {
    if (tableNumber.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter table number")));
      return;
    }

    if (cart.isEmpty) return;

    isSubmitting = true;
    notifyListeners();

    try {
      await db.collection('orders').add({
        'waiterId': auth.currentUser?.uid,
        'tableNumber': tableNumber,
        'notes': specialNotes,
        'status': 'pending',
        'totalAmount': total,
        'createdAt': FieldValue.serverTimestamp(),
        'items': cart.map((item) => {
          'menuItemId': item.id,
          'vendorId': item.vendorId,
          'name': item.name,
          'quantity': item.quantity,
          'price': item.price,
          'status': 'pending',
        }).toList()
      });

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

  /// ✅ Mark as Delivered / Complete Handover
  Future<void> completeHandover(String orderId, String paymentMethod) async {
    final order = orders.firstWhere((o) => o.id == orderId);
    
    final updatedItems = order.items.map((item) => {
      'name': item.name,
      'vendorId': item.vendorId,
      'quantity': item.quantity,
      'price': item.price,
      'status': 'delivered',
    }).toList();

    await db.collection('orders').doc(orderId).update({
      'status': 'delivered',
      'paymentMethod': paymentMethod,
      'items': updatedItems,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
