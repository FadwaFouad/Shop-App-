import 'package:Shop/providers/products.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool isFavorite;
  const ProductsGrid({
    Key key,
     this.isFavorite,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
     final productsdata = Provider.of<Products>(context);
    var loadedProducts = isFavorite? productsdata.getFavoriteItems:productsdata.getItems;

    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: loadedProducts.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: loadedProducts.elementAt(index),
        child: ProductItem(
            // title: loadedProducts.elementAt(index).title,
            // id: loadedProducts.elementAt(index).id,
            // imageUrl: loadedProducts.elementAt(index).imageUrl,
            ),
      ),
    );
  }
}
