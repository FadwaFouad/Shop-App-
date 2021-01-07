import 'package:Shop/providers/products.dart';
import 'package:Shop/screens/edit_product_screen.dart';
import 'package:Shop/widgets/app_drawer.dart';
import 'package:Shop/widgets/user_input_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInputScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/user_input';

  Future<void> refreshData(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    print('building ..');
    return Scaffold(
        appBar: AppBar(
          title: Text('User Products'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.ROUTE_NAME);
              },
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: refreshData(context),
            builder: (ctx, dataSnapshut) {
              if (dataSnapshut.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(),
                );
              if (dataSnapshut.error != null)
                return Center(
                  child: Text('error'),
                );
              else
                return RefreshIndicator(
                    onRefresh: () =>
                        refreshData(context),
                    child: Consumer<Products>(
                      builder: (ctx, products, child) => ListView.builder(
                        itemBuilder: (_, i) => UserInputItem(
                          id: products.getItems[i].id,
                          title: products.getItems[i].title,
                          imageUrl: products.getItems[i].imageUrl,
                        ),
                        itemCount: products.getItems.length,
                      ),
                    ));
            }));
  }
}
