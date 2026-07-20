import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/menu_item.dart';

class MenuProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<MenuItem> _items = [];
  bool _isLoading = true;

  List<MenuItem> get items => _items;
  bool get isLoading => _isLoading;

  void listenItems() {
    _db.collection('menu_items').snapshots().listen((snapshot) {
      _items = snapshot.docs
          .map((doc) => MenuItem.fromJson(doc.id, doc.data()))
          .toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> saveItem(MenuItem item) async {
    final data = item.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();

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
