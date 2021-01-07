import 'package:Shop/providers/product.dart';
import 'package:Shop/providers/products.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/edit_product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  FocusNode _priceFoucs = FocusNode();
  FocusNode _desFoucs = FocusNode();
  FocusNode _imageFoucs = FocusNode();
  TextEditingController _imageController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Product _editedProduct = Product(
    id: null,
    imageUrl: '',
    title: '',
    price: 0,
  );
  bool _isInit = true;
  bool _isLoading = false;

  void updateImage() {
    if (!_imageFoucs.hasFocus) {
      if ((!_imageController.text.startsWith('http') &&
              !_imageController.text.startsWith('https')) ||
          (!_imageController.text.endsWith('.jpg') &&
              !_imageController.text.endsWith('.jpeg') &&
              !_imageController.text.endsWith('.png'))) return;
    }
  }

  void saveForm() async {
    final isValid = _form.currentState.validate();
    if (isValid) {
      _form.currentState.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_editedProduct.id == null)
          await Provider.of<Products>(context, listen: false)
              .addItem(_editedProduct);
        else
          await Provider.of<Products>(context, listen: false)
              .updateItem(_editedProduct);
      } catch (_) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error Occured !!'),
            content: Text('Something went Wrong !!'),
            actions: [
              FlatButton(
                  child: Text('Okey'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  })
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    _imageFoucs.addListener(updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null)
        _editedProduct =
            Provider.of<Products>(context, listen: false).getItem(productId);
      _imageController.text = _editedProduct.imageUrl;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageFoucs.removeListener(updateImage);
    _priceFoucs.dispose();
    _desFoucs.dispose();
    _imageFoucs.dispose();
    _imageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      initialValue: _editedProduct.title,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFoucs);
                      },
                      onSaved: (value) {
                        _editedProduct.setTitle(value);
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Title should not be empty';
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Price'),
                      initialValue: _editedProduct.price.toString(),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      focusNode: _priceFoucs,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_desFoucs);
                      },
                      onSaved: (value) {
                        _editedProduct.setPrice(double.parse(value));
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Price should not be empty';
                        if (double.tryParse(value) == null)
                          return 'You shouldenter valid Number';
                        if (double.parse(value) <= 0)
                          return 'Price should be greater than Zero!!';
                        return null;
                      },
                    ),
                    TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        initialValue: _editedProduct.description,
                        maxLines: 3,
                        focusNode: _desFoucs,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        onSaved: (value) {
                          _editedProduct.setDescription(value);
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Descreption should not be empty';
                          if (value.length < 10)
                            return 'Descreption should be longer !! \n add more Specification ';
                          return null;
                        }),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          child: _imageController.text.isEmpty
                              ? Text('No Image')
                              : Image.network(
                                  _imageController.text,
                                  fit: BoxFit.cover,
                                ),
                          margin: EdgeInsets.only(top: 10, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              //initialValue: _editedProduct.title,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.url,
                              focusNode: _imageFoucs,
                              controller: _imageController,
                              onFieldSubmitted: (_) {
                                saveForm();
                              },
                              onSaved: (value) {
                                _editedProduct.setImageUrl(value);
                              },
                              validator: (value) {
                                if (value.isEmpty)
                                  return 'Image URl should not be empty';
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https'))
                                  return 'invalid URL';
                                if (!value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg') &&
                                    !value.endsWith('.png'))
                                  return 'invalid Image URL';
                                return null;
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
