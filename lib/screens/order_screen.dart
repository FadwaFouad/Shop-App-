import 'package:Shop/providers/order.dart';
import 'package:Shop/widgets/app_drawer.dart';
import 'package:Shop/widgets/order_item.dart' as ord;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatelessWidget {
  static const ROUTE_NAME = '/order';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: FutureBuilder(
          future: Provider.of<Order>(context,listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (dataSnapshot.error != null) {
              return Center(
                child: Text('Error !!'),
              );
            } else {
              return Consumer<Order>(
                builder: (ctx, order, child) => ListView.builder(
                  itemBuilder: (ctx, index) =>
                      ord.OrderItem(order.items.elementAt(index)),
                  itemCount: order.items.length,
                ),
              );
            }
          }),
    );
  }
}
