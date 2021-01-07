import 'package:Shop/providers/products.dart';
import 'package:Shop/screens/edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInputItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserInputItem({
    Key key,
    this.id,
    this.title,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
   final scaffold= Scaffold.of(context);
    return Card(
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(title),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(EditProductScreen.ROUTE_NAME, arguments: id);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
                onPressed: () async {
                  try {
                     await Provider.of<Products>(context, listen: false)
                        .removeItem(id);
                  } catch (error) {
                    scaffold.removeCurrentSnackBar();
                    scaffold.showSnackBar(SnackBar(
                      content: Text(
                        'Delete Failed!!' ,
                        textAlign: TextAlign.center,
                      ),
                    ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
