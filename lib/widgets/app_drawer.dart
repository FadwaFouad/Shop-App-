import 'package:Shop/helper/custom_route_transition.dart';
import 'package:Shop/providers/auth.dart';
import 'package:Shop/screens/order_screen.dart';
import 'package:Shop/screens/user_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  List<Widget> buildDrawerItem(
    Function handler,
    String title,
    IconData icon,
  ) {
    return [
      ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: handler,
      ),
      Divider(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello Freind!!'),
            automaticallyImplyLeading: false,
          ),
          ...buildDrawerItem(
              () => Navigator.of(context).pushReplacementNamed('/'),
              'Products',
              Icons.shop),
          ...buildDrawerItem(
            () => Navigator.of(context)
                .pushReplacementNamed(OrderScreen.ROUTE_NAME),
            // CustomRouteTransition(builder: (ctx) => OrderScreen())),

            'Orders',
            Icons.payment,
          ),
          ...buildDrawerItem(
              () => Navigator.of(context)
                  .pushReplacementNamed(UserInputScreen.ROUTE_NAME),
              'Mange Products',
              Icons.edit),
          ...buildDrawerItem(
            () {
              //Navigator.of(context).pop();
              Provider.of<Auth>(context, listen: false).logOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
            'Log out',
            Icons.exit_to_app,
          ),
        ],
      ),
    );
  }
}
