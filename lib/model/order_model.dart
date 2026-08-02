import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String id;
  String waiterId;
  String tableNumber;
  String status;
  double totalAmount;
  String? paymentMethod;
  String? notes;
  DateTime createdAt;
  List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.waiterId,
    required this.tableNumber,
    required this.status,
    required this.totalAmount,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      waiterId: data['waiterId'] ?? '',
      tableNumber: data['tableNumber']?.toString() ?? '',
      status: data['status'] ?? 'pending',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['paymentMethod'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: (data['items'] as List? ?? [])
          .map((item) => OrderItem.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'waiterId': waiterId,
      'tableNumber': tableNumber,
      'status': status,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt,
      'items': items.map((i) => i.toMap()).toList(),
    };
  }
}

class OrderItem {
  String name;
  String vendorId;
  double price;
  int quantity;
  String status;

  OrderItem({
    required this.name,
    required this.vendorId,
    required this.price,
    required this.quantity,
    required this.status,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      name: data['name'] ?? '',
      vendorId: data['vendorId'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 0,
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'vendorId': vendorId,
      'price': price,
      'quantity': quantity,
      'status': status,
    };
  }
}
