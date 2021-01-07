import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/order.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItem(
    this.order, {
    Key key,
  }) : super(key: key);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          ListTile(
            leading: Chip(
              label: Text(
                widget.order.total.toStringAsFixed(2),
              ),
            ),
            title: Text(
              DateFormat('dd/MM/yyyy').format(widget.order.date),
            ),
            trailing: IconButton(
              icon: isExpanded
                  ? Icon(Icons.expand_less)
                  : Icon(Icons.expand_more),
              onPressed: () => setState(() {
                isExpanded = !isExpanded;
              }),
            ),
          ),
          //if (isExpanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
            height: isExpanded ? 100 : 0,
            //padding: EdgeInsets.all(5),
            margin: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(5)),
            child: SingleChildScrollView(
              child: Column(
                children: widget.order.products
                    .map(
                      (prod) => ListTile(
                        leading: Text(prod.price.toString()),
                        title: Text(prod.title),
                        trailing: Text(prod.quantity.toString()),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
