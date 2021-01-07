import 'package:Shop/providers/Cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final double price;
  final String title;
  final int quantity;
  final String productId;

  const CartItem({
    Key key,
    this.id,
    this.price,
    this.title,
    this.quantity,
    this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(
      context,
      listen: false,
    );
    return Dismissible(
      key: Key(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          size: 25,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction)=>showDialog(
        context: context,
        builder:(ctx) =>AlertDialog(
          content: Text('Do you want to remove this Cart?'),
          title: Text('Remove cart'),
          actions: [
            FlatButton(
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
      onDismissed: (_) => cart.remove(productId),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        elevation: 5,
        child: ListTile(
          leading: Chip(
            backgroundColor: Theme.of(context).primaryColor,
            label: Text(
              '\$$price',
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Text(title),
          subtitle: Text('${(price * quantity)}'),
          trailing: Text('$quantity x'),
        ),
      ),
    );
  }
}
