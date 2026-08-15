import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/booking_model.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String? _restaurantId;
  StreamSubscription? _bookingsSubscription;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> _fetchRestaurantId() async {
    if (_restaurantId != null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _restaurantId = doc.data()?['restaurantId'];
        debugPrint("Fetched Restaurant ID: $_restaurantId");
      }
    }
  }

  void listenBookings() async {
    _isLoading = true;
    notifyListeners();
    
    await _fetchRestaurantId();
    
    if (_restaurantId == null) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error: Restaurant ID is null");
      return;
    }

    // Cancel existing subscription if any
    await _bookingsSubscription?.cancel();

    _bookingsSubscription = _db
        .collection('bookings')
        .where('restaurantId', isEqualTo: _restaurantId)
        .snapshots()
        .listen((snapshot) {
      _bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
      
      // Sort manually to avoid index requirement for now
      _bookings.sort((a, b) => b.startDate.compareTo(a.startDate));
      
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint("Firestore Error: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createBooking(BookingModel booking) async {
    try {
      await _fetchRestaurantId();
      if (_restaurantId == null) {
        debugPrint("Cannot create booking: Restaurant ID is null");
        return;
      }

      final data = booking.toJson();
      data['restaurantId'] = _restaurantId;
      await _db.collection('bookings').add(data);
      debugPrint("Booking created successfully");
    } catch (e) {
      debugPrint("Error creating booking: $e");
    }
  }

  Future<void> updateBooking(BookingModel booking) async {
    await _db.collection('bookings').doc(booking.id).update(booking.toJson());
  }

  Future<void> deleteBooking(String id) async {
    await _db.collection('bookings').doc(id).delete();
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
