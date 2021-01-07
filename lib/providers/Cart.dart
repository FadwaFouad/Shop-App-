import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({this.id, this.title, this.price, this.quantity});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> products = {};
  bool _isOrder = true;
  final String token;

  Cart(this.token,this.products);

  double get totalPrice {
    double total = 0;
    products.values.forEach((prod) {
      total += prod.quantity * prod.price;
    });
    return total;
  }

  Map<String, CartItem> get items => {...products};
  bool get isOrder => _isOrder;

  void ordered() {
    _isOrder = true;
    notifyListeners();
  }

  int get quantityCount {
    int quantity = 0;
    products.forEach((key, prod) {
      quantity += prod.quantity;
    });
    return quantity;
  }

  Future<void> fetchAndSetCarts() async {
    final url = 'https://shop-b3c0c.firebaseio.com/products.json?auth=$token';
    try {
      final response = await http.get(url);
      final extractData = json.decode(response.body) as Map<String, dynamic>;
      Map<String, CartItem> loadedProducts = {};
      extractData.forEach((prodId, value) {
        final order = value['orders'] as Map<String, dynamic>;

        if (order != null) {
          _isOrder = false;

          loadedProducts.putIfAbsent(
            prodId,
            () => CartItem(
              id: order.keys.first,
              title: order.values.first['title'],
              price: order.values.first['price'],
              quantity: order.values.first['quantity'],
            ),
          );

          products = loadedProducts;
          notifyListeners();
        }
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addItem(String productId, String title, double price) async {
    _isOrder = false;
    if (products.containsKey(productId)) {
      final orderId = products[productId].id;

      final url =
          'https://shop-b3c0c.firebaseio.com/products/$productId/orders/$orderId.json?auth=$token';

      final exitingQuantity = products[productId].quantity;

      await http.patch(url,
          body: json.encode({
            'quantity': (exitingQuantity + 1),
          }));

      products.update(
        productId,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          price: value.price,
          quantity: value.quantity + 1,
        ),
      );
      notifyListeners();
    } else {
      final url =
          'https://shop-b3c0c.firebaseio.com/products/$productId/orders.json?auth=$token';

      final response = await http.post(url,
          body: json.encode({
            'title': title,
            'price': price,
            'quantity': 1,
          }));

      products.putIfAbsent(
        productId,
        () => CartItem(
          id: json.decode(response.body)['name'],
          title: title,
          price: price,
          quantity: 1,
        ),
      );
      notifyListeners();
    }
  }

  void removeSingleItem(String productId) {
    if (!products.containsKey(productId)) return;
    if (products[productId].quantity > 1) {
      products.update(
          productId,
          (existing) => CartItem(
                quantity: existing.quantity - 1,
                id: existing.id,
                price: existing.price,
                title: existing.title,
              ));
    } else
      remove(productId);
    notifyListeners();
  }

  void remove(String productId) async {
    final url =
        'https://shop-b3c0c.firebaseio.com/products/$productId/orders.json?auth=$token';
    await http.delete(url);
    products.remove(productId);
    notifyListeners();
  }

  Future<void> clear() async {
    products.forEach((productId, value) async {
      final url =
          'https://shop-b3c0c.firebaseio.com/products/$productId/orders.json';
      await http.delete(url);
    });
    products = {};
    notifyListeners();
  }
}
