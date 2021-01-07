import 'package:Shop/helper/custom_route_transition.dart';
import 'package:Shop/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/Cart.dart';
import './providers/products.dart';
import './providers/order.dart';
import './screens/auth_screen.dart';
import './screens/cart_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/order_screen.dart';
import './screens/user_input_screen.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(null, null, []),
          update: (ctx, auth, previosProducts) => Products(
              auth.token,
              auth.userId,
              previosProducts == null ? [] : previosProducts.getItems),
        ),
        ChangeNotifierProxyProvider<Auth, Cart>(
          create: (ctx) => Cart(null, {}),
          update: (ctx, auth, previosCart) =>
              Cart(auth.token, previosCart == null ? [] : previosCart.items),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (ctx) => Order(null, null, []),
          update: (ctx, auth, previosOrder) => Order(auth.token, auth.userId,
              previosOrder == null ? [] : previosOrder.items),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, child) => MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          routes: {
            '/': (ctx) => auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryLogin(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return SplashScreen();
                      return AuthScreen();
                    }),
            ProductDetailScreen.ROUTE_NAME: (ctx) => ProductDetailScreen(),
            CartScreen.ROUTE_NAME: (ctx) => CartScreen(),
            OrderScreen.ROUTE_NAME: (ctx) => OrderScreen(),
            UserInputScreen.ROUTE_NAME: (ctx) => UserInputScreen(),
            EditProductScreen.ROUTE_NAME: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
