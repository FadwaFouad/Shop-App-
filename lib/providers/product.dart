import 'dart:convert';

import 'package:Shop/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  String imageUrl;
  double price;
  bool isFavorite;

  Product({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.price,
    this.isFavorite = false,
  });

  void setId(String id) {
    this.id = id;
  }

  void setPrice(double price) {
    this.price = price;
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setImageUrl(String imageUrl) {
    this.imageUrl = imageUrl;
  }

  void setDescription(String description) {
    this.description = description;
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    isFavorite = !isFavorite;
    notifyListeners();
    final url = 'https://shop-b3c0c.firebaseio.com/favorits/$userId/$id.json?auth=$token';
    try {
      final response = await http.put(url,
          body: json.encode(
             isFavorite,
          ));
      if (response.statusCode >= 400)
        throw HttpException('cann\'t toggle Favorite Status');
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw error;
    }
  }
}
