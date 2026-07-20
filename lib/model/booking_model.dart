import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String eventType;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double totalPrice;

  BookingModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalPrice,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      eventType: data['eventType'] ?? 'Party',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'eventType': eventType,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'totalPrice': totalPrice,
    };
  }
}
