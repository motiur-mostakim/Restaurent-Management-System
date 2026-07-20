import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/order_model.dart';

class DashboardProvider with ChangeNotifier {
  double totalSales = 0;
  int totalOrders = 0;
  double vendor1Revenue = 0;
  double vendor2Revenue = 0;
  int activeBookings = 0;
  int totalMenuItems = 0;

  List<OrderModel> recentOrders = [];

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> checkAndSeed() async {
    final menuSnap = await db.collection('menu_items').limit(1).get();
    if (menuSnap.docs.isEmpty) {
      debugPrint('Seeding initial data...');
      final menuItems = [
        {
          'name': 'Classic Cheeseburger',
          'price': 12.99,
          'vendorId': 'fast_food',
          'category': 'fast_food',
          'available': true,
        },
        {
          'name': 'Crispy Chicken Wings',
          'price': 9.50,
          'vendorId': 'fast_food',
          'category': 'fast_food',
          'available': true,
        },
        {
          'name': 'Truffle Fries',
          'price': 6.75,
          'vendorId': 'fast_food',
          'category': 'fast_food',
          'available': true,
        },
        {
          'name': 'Caramel Macchiato',
          'price': 5.25,
          'vendorId': 'beverages',
          'category': 'beverages',
          'available': true,
        },
        {
          'name': 'Fresh Tropical Juice',
          'price': 4.50,
          'vendorId': 'beverages',
          'category': 'beverages',
          'available': true,
        },
        {
          'name': 'Cold Brew Coffee',
          'price': 4.00,
          'vendorId': 'beverages',
          'category': 'beverages',
          'available': true,
        },
      ];
      for (var item in menuItems) {
        await db.collection('menu_items').add(item);
      }

      final bookings = [
        {
          'customerName': 'John Doe',
          'customerPhone': '555-0123',
          'eventType': 'Birthday Party',
          'startDate': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 1)),
          ),
          'endDate': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 1, hours: 1)),
          ),
          'status': 'confirmed',
          'totalPrice': 250,
        },
      ];
      for (var booking in bookings) {
        await db.collection('bookings').add(booking);
      }
    }
  }

  void listenData() {
    checkAndSeed();

    db.collection('orders').snapshots().listen((snapshot) {
      double sales = 0;
      double v1 = 0;
      double v2 = 0;

      List<OrderModel> orders = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();

        sales += (data['totalAmount'] ?? 0).toDouble();

        List items = data['items'] ?? [];
        for (var item in items) {
          if (item['vendorId'] == 'fast_food') {
            v1 +=
                (item['price'] ?? 0).toDouble() *
                (item['quantity'] ?? 0).toDouble();
          } else if (item['vendorId'] == 'beverages') {
            v2 +=
                (item['price'] ?? 0).toDouble() *
                (item['quantity'] ?? 0).toDouble();
          }
        }

        orders.add(
          OrderModel(
            id: doc.id,
            waiterId: data['waiterId'] ?? '',
            tableNumber: data['tableNumber']?.toString() ?? '',
            status: data['status'] ?? 'pending',
            totalAmount: (data['totalAmount'] ?? 0).toDouble(),
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            items: [],
          ),
        );
      }

      totalSales = sales;
      totalOrders = snapshot.size;
      vendor1Revenue = v1;
      vendor2Revenue = v2;

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      recentOrders = orders.take(5).toList();

      notifyListeners();
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
}
