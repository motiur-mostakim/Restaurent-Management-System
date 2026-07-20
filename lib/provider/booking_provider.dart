import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/booking_model.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  void listenBookings() {
    _db
        .collection('bookings')
        .orderBy('startDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createBooking(BookingModel booking) async {
    await _db.collection('bookings').add(booking.toJson());
  }

  Future<void> deleteBooking(String id) async {
    await _db.collection('bookings').doc(id).delete();
  }
}
