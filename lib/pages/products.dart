import 'package:cash_register/services/database.dart';
import 'package:cash_register/models/product.dart';
import 'package:flutter/material.dart';
import 'package:cash_register/components/modals/product_modal.dart';
import 'package:cash_register/components/modals/delete_product_modal.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage(
      {Key? key, required this.title, this.id, required this.navigatorKey})
      : super(key: key);

  final String title;
  final String? id;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late List<Product> list = [];
  final searchController = TextEditingController();
  final int _limit = 50;
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<int> loadProducts({String search = '', int page = 1}) async {
    String sql = 'SELECT * FROM products';
    List<Object?> params = [];
    int offset = (page - 1) * _limit;

    if (search != '') {
      sql += ' WHERE (name LIKE ? OR code=?)';
      params.add('%$search%');
      params.add(search);
    }
    sql += ' ORDER BY name';
    sql += ' LIMIT $_limit';
    sql += ' OFFSET $offset';
    List<Product> products = await Product.query(sql, params: params);

    setState(() {
      if (page == 1) {
        list = products;
        _page = 1;
      } else {
        list.addAll(products);
      }
    });
    return products.length;
  }

  Widget _createListView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if (!_isLoading) {
          _isLoading = true;
          _page++;
          int count = await loadProducts(search: searchController.text, page: _page);
          _isLoading = count != _limit;
        }
      }
    });

    return ListView.builder(
      controller: scrollController,
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        Product item = list[index];
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.keyboard_arrow_right),
            ),
            title: Text('${item.name}, ${item.code}'),
            subtitle: Text('Price: ${item.price}, Vat: ${item.vatName} ${item.vatPercentage}%, Includes vat: ${item.vatIncluded}'),
            trailing: GestureDetector(
              child: const Icon(Icons.delete),
              onTap: () {
                deleteProductModal(context, item, () => loadProducts());
              },
            ),
            onTap:() {
              productModal(context, item, () => loadProducts());
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                loadProducts(search: value);
              },
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0))
                )
              ),
            ),
          ),
          Expanded(
            child: _createListView()
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productModal(context, Product(name:''), () => loadProducts());
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }
}