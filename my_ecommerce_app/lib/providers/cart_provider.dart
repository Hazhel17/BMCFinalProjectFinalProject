import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String title;
  final String genre;
  final String format;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.genre,
    required this.format,
    this.quantity = 1,
  });

  // 1. A method to convert our CartItem object into a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'price': price,
      'quantity': quantity,
      'genre': genre,
      'format': format,
    };
  }

  // 2. A factory constructor to create a CartItem from a Map
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      title: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      genre: json['genre'],
      format: json['format'],
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String? _userId;
  StreamSubscription? _authSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Existing Getters (Unchanged)
  List<CartItem> get items => _items;

  // 1. RENAME 'totalPrice' to 'subtotal'
  // This is the total price *before* tax. [cite: 14]
  double get subtotal {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  // 2. ADD this new getter for VAT (12%)
  double get vat {
    return subtotal * 0.12; // 12% of the subtotal [cite: 23, 36]
  }

  // 3. ADD this new getter for the FINAL total
  double get totalPriceWithVat {
    return subtotal + vat; // subtotal + vat [cite: 27, 37]
  }

  // Update 'itemCount' to be cleaner [cite: 29]
  int get itemCount {
    // This 'fold' is a cleaner way to sum a list. [cite: 32]
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  // 7. Constructor (FIX: Now empty, replacing the logic that caused the deadlock)
  CartProvider() {
    print('CartProvider created.');
  }

  // FIX: This new public method contains all the logic that used to be in the constructor.
  void initializeAuthListener() {
    print('CartProvider auth listener initialized');
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User logged out, clearing cart.');
        _userId = null;
        _items = [];
      } else {
        print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }


  // 8. Fetches the cart from Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return;
    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();

      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        print('Cart fetched successfully: ${_items.length} items');
      } else {
        _items = [];
      }
    } catch (e) {
      print('Error fetching cart: $e');
      _items = [];
    }
    notifyListeners();
  }

  // 9. Saves the current local cart to Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return;
    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
      print('Cart saved to Firestore');
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Creates an order in the 'orders' collection (UPDATED to save breakdown) [cite: 38]
  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      // 1. THIS IS THE CHANGE: Get all our new calculated values [cite: 50, 51]
      final double sub = subtotal; // [cite: 52]
      final double v = vat; // [cite: 53]
      final double total = totalPriceWithVat; // [cite: 54]
      final int count = itemCount; // [cite: 55]

      // 2. Update the data we save to Firestore [cite: 56]
      await _firestore.collection('orders').add({
        'userId': _userId, // [cite: 57]
        'items': cartData, // Our list of item maps [cite: 58]
        'subtotal': sub, // [cite: 59]
        'vat': v, // 3. ADD THIS [cite: 60, 61]
        'totalPrice': total, // 4. ADD THIS; 5. This is now the VAT-inclusive price [cite: 62, 63]
        'itemCount': count, // [cite: 64]
        'status': 'Pending', // For admin verification [cite: 65]
        'createdAt': FieldValue.serverTimestamp(), // For sorting [cite: 66]
      });

      // --- END OF CHANGE [cite: 68]
    } catch (e) {
      print('Error placing order: $e');
      throw e;
    }
  }

  // Clears the cart locally AND in Firestore
  Future<void> clearCart() async {
    _items = [];

    if (_userId != null) {
      try {
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        print('Firestore cart cleared.');
      } catch (e) {
        print('Error clearing Firestore cart: $e');
      }
    }

    notifyListeners();
  }

  // 2. THIS IS THE NEW, UPDATED addItem FUNCTION:
  void addItem(
      String id,
      String title,
      double price,
      String genre,
      String format,
      int quantity, // NEW: Accept the quantity
      ) {
    // 3. Check if the item is already in the cart
    var index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      // 4. If YES: Add the new quantity to the existing quantity
      _items[index].quantity += quantity;
    } else {
      // 5. If NO: Add the item with the specified quantity
      _items.add(
        CartItem(
          id: id,
          title: title,
          price: price,
          genre: genre,
          format: format,
          quantity: quantity, // Use the quantity from the parameter
        ),
      );
    }
    _saveCart();
    notifyListeners();
  }

  // Updated removeItem function (unchanged from the original provided code)
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);

    _saveCart();
    notifyListeners();
  }

  // 12. Dispose method
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}