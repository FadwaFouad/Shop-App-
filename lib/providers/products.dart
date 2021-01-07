import 'dart:convert';

import 'package:Shop/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _products = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String token;
  final String userId;

  Products(this.token, this.userId, this._products);

  List<Product> get getItems {
    return [..._products];
  }

  List<Product> get getFavoriteItems {
    return _products.where((prod) => prod.isFavorite).toList();
  }

  Product getItem(String productId) {
    return _products.firstWhere((prod) => prod.id == productId);
  }

  Future<void> fetchAndSetProducts([bool filter = false]) async {
    _products=[];
    final filterString = filter ? 'orderBy="userId"&equalTo="$userId"' : '';
    var url = 'https://shop-b3c0c.firebaseio.com/products.json?auth=$token&$filterString';
    try {
      var response = await http.get(url);
      print(json.decode(response.body));
      final extractData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractData == null) return;
      extractData.forEach((prodId, value) async {
        url =
            'https://shop-b3c0c.firebaseio.com/favorits/$userId/$prodId.json?auth=$token';
        response = await http.get(url);
        final loadedFavorite = json.decode(response.body);
        loadedProducts.add(
          Product(
            id: prodId,
            description: value['description'],
            imageUrl: value['imageUrl'],
            isFavorite: loadedFavorite==null?false:loadedFavorite,
            price: value['price'],
            title: value['title'],
          ),
        );
        _products = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addItem(Product newProduct) async {
    final url = 'https://shop-b3c0c.firebaseio.com/products.json?auth=$token';
    try {
      final res = await http.post(url,
          body: json.encode({
            'userId': userId,
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));

      print(res.toString() + ' \n' + res.body.toString());
      final product = Product(
        id: json.decode(res.body)['name'],
        title: newProduct.title,
        price: newProduct.price,
        description: newProduct.description,
        imageUrl: newProduct.imageUrl,
      );
      _products.add(product);
      notifyListeners();
    } catch (error) {
      print(error.toString() + ' \n' + error.toString());
      throw error;
    }
  }

  Future<void> updateItem(Product editedProduct) async {
    final url =
        'https://shop-b3c0c.firebaseio.com/products/${editedProduct.id}.json?auth=$token';

    try {
      await http.patch(url,
          body: json.encode({
            'title': editedProduct.title,
            'description': editedProduct.description,
            'imageUrl': editedProduct.imageUrl,
            'price': editedProduct.price,
          }));

      final updateIndex =
          _products.indexWhere((element) => element.id == editedProduct.id);
      _products[updateIndex] = editedProduct;
      notifyListeners();
      print('inside try');
    } catch (error) {
      print('catch error');
      throw error;
    } finally {
      print('finally');
    }
    print('end update');
  }

  Future<void> removeItem(String id) async {
    int itemIndex = _products.indexWhere((element) => element.id == id);
    if (itemIndex < 0) return;
    Product temProduct = _products[itemIndex];
    _products.removeAt(itemIndex);
    notifyListeners();

    final url =
        'https://shop-b3c0c.firebaseio.com/products/$id.json?auth=$token';
    try {
      final res = await http.delete(url);
      if (res.statusCode >= 400) throw HttpException('Delete Failed');
    } catch (error) {
      _products.insert(itemIndex, temProduct);
      notifyListeners();
      throw error;
    }
    temProduct = null;
  }
}
