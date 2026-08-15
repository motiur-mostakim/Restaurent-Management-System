import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/menu_item.dart';

class MenuProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<MenuItem> _items = [];
  bool _isLoading = true;
  String? _restaurantId;

  List<MenuItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> _fetchRestaurantId() async {
    if (_restaurantId != null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _restaurantId = doc.data()?['restaurantId'];
      }
    }
  }

  void listenItems() async {
    _isLoading = true;
    notifyListeners();
    
    await _fetchRestaurantId();
    if (_restaurantId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _db.collection('menu_items')
      .where('restaurantId', isEqualTo: _restaurantId)
      .snapshots()
      .listen((snapshot) {
      _items = snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.id, doc.data()))
          .toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> saveItem(MenuItem item) async {
    await _fetchRestaurantId();
    if (_restaurantId == null) return;

    final data = item.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    data['restaurantId'] = _restaurantId;

    if (item.id.isEmpty) {
      data['createdAt'] = FieldValue.serverTimestamp();
      await _db.collection('menu_items').add(data);
    } else {
      await _db.collection('menu_items').doc(item.id).update(data);
    }
  }

  Future<void> deleteItem(String id) async {
    await _db.collection('menu_items').doc(id).delete();
  }

  Future<void> toggleAvailability(MenuItem item) async {
    await _db.collection('menu_items').doc(item.id).update({
      'available': !item.available,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
