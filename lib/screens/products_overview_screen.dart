import 'package:Shop/providers/products.dart';
import 'package:Shop/widgets/app_drawer.dart';
import 'package:flutter/Material.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../providers/Cart.dart';
import '../widgets/badge.dart';
import 'cart_screen.dart';

enum FilterOptions {
  Favorite,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _isFavorite = false;
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    setState(() {
      _isLoading = false;
    });
    if (_isInit) {
      Provider.of<Products>(context).fetchAndSetProducts();
       Provider.of<Cart>(context).fetchAndSetCarts();
      setState(() {
        _isLoading = true;
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void selectFilter(
    FilterOptions filter,
  ) {
    setState(() {
      if (filter == FilterOptions.Favorite)
        _isFavorite = true;
      else
        _isFavorite = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('The Products'),
        actions: [
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.quantityCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.ROUTE_NAME),
            ),
          ),
          PopupMenuButton(
            onSelected: (filter) => selectFilter(filter),
            icon: Icon(Icons.more_vert),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: Text('Only Favorits'),
                value: FilterOptions.Favorite,
              ),
              PopupMenuItem(
                child: Text('show all'),
                value: FilterOptions.All,
              ),
            ],
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(isFavorite: _isFavorite),
    );
  }
}
