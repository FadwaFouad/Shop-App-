import 'package:Shop/providers/Cart.dart';
import 'package:Shop/providers/auth.dart';
import 'package:Shop/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  void selectProduct(BuildContext ctx, String id) {
    Navigator.of(ctx).pushNamed(
      ProductDetailScreen.ROUTE_NAME,
      arguments: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: InkWell(
          onTap: () => selectProduct(context, product.id),
          child: Hero(
            tag: product.id,
            
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(product.title),
          leading: Consumer<Product>(
            builder: (context, value, child) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () async {
                try {
                  await product.toggleFavoriteStatus(auth.token, auth.userId);
                } catch (error) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Error !! , Try Later ',
                      textAlign: TextAlign.center,
                    ),
                  ));
                }
              },
            ),
          ),
          trailing: IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                cart.addItem(
                  product.id,
                  product.title,
                  product.price,
                );
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('New Item added to Cart'),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => cart.removeSingleItem(product.id)),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
