import 'dart:convert';

import 'package:Shop/providers/Cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final List<CartItem> products;
  DateTime date = DateTime.now();
  double total = 0;

  OrderItem({this.id, this.products, this.date, this.total});
}

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String token;
  final String userId;

  Order(this.token,this.userId,this._orders);

  List<OrderItem> get items => _orders;

  Future<void> fetchAndSetOrders() async {
    final url = 'https://shop-b3c0c.firebaseio.com/$userId/orders.json?auth=$token';
    try {
      final response = await http.get(url);
      final extractData = json.decode(response.body) as Map<String, dynamic>;
      List<OrderItem> loadedOrders = [];
      if (extractData == null ) return ;
      extractData.forEach((orderId, orderValue) {
        final productsMap = orderValue['products'] as Map<String, dynamic>;
        List<CartItem> loadedProducts = [];

        productsMap.forEach((key, prodValue) {
          loadedProducts.add(CartItem(
            id: key,
            price: prodValue['price'],
            quantity: prodValue['quantity'],
            title: prodValue['title'],
          ));
        });

        loadedOrders.add(
          OrderItem(
            id: orderId,
            products: loadedProducts,
            total: orderValue['total'],
            date:  DateTime.parse(orderValue['date'])  ,
          ),
        );

         _orders = loadedOrders.reversed.toList();
        notifyListeners();
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addItem(List<CartItem> products, double total) async {
    final url = 'https://shop-b3c0c.firebaseio.com/$userId/orders.json?auth=$token';
    Map<String, dynamic> productsMap = {};

    products.forEach((element) => {
          productsMap.putIfAbsent(
              element.id,
              () => {
                    'price': element.price,
                    'title': element.title,
                    'quantity': element.quantity,
                  })
        });
final timeStamp=DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'total': total,
          'date': timeStamp.toIso8601String(),
          'products': productsMap,
        }));

    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          products: products,
          date: timeStamp,
          total: total,
        ));
  }
}
