import 'package:Shop/providers/order.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/Cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const ROUTE_NAME = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  Future<void> onPressOrder(
    BuildContext context,
  ) async {
    final cart = Provider.of<Cart>(context,listen: false);
    if (!cart.isOrder) {
      setState(() {
        _isLoading = true;
      });

      cart.ordered();
      await Provider.of<Order>(context, listen: false)
          .addItem(cart.items.values.toList(), cart.totalPrice);
      await cart.clear();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Products Cart')),
      body: Column(
        children: [
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '  Total: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Chip(
                  backgroundColor: Theme.of(context).primaryColor,
                  label: Text(
                    '${cart.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () => onPressOrder(context),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          cart.isOrder ? 'Ordered' : 'Order Now',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) => CartItem(
                id: cart.items.values.elementAt(index).id,
                productId: cart.items.keys.elementAt(index),
                price: cart.items.values.elementAt(index).price,
                quantity: cart.items.values.elementAt(index).quantity,
                title: cart.items.values.elementAt(index).title,
              ),
              itemCount: cart.items.length,
            ),
          )
        ],
      ),
    );
  }
}
