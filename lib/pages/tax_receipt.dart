import 'dart:async';

import 'package:cash_register/models/docs/tax_receipt.dart';
import 'package:cash_register/models/docs/tax_receipt_product.dart';
import 'package:cash_register/models/product.dart';
import 'package:cash_register/services/drivers/datecs_driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:intl/intl.dart';
import 'package:cash_register/pages/tax_receipt/delete_product_modal.dart';

class TaxReceiptPage extends StatefulWidget {
  const TaxReceiptPage({Key? key, required this.title, required this.navigatorKey})
      : super(key: key);
  final String title;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<TaxReceiptPage> createState() => _TaxReceiptPageState();
}

class _TaxReceiptPageState extends State<TaxReceiptPage> {
  late List<TaxReceiptProduct> list = [];
  TaxReceipt receipt = TaxReceipt(issueDate: '', workStationId: 0);

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() async {
    String sql = 'SELECT * FROM tax_receipts WHERE isNew=1 LIMIT 1';
    List<TaxReceipt> result = await TaxReceipt.query(sql);
    if (result.isNotEmpty) {
      receipt = result.first;
      list = await receipt.products();
    } else {
      receipt = TaxReceipt(
        issueDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        workStationId: 0,
        isNew: true,
      );
      receipt.save();
      list = [];
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double containerWidth = (double width) {
      if (width > 767) {
        int splitCols = width > 1200 ? 4 : 3;
        return (width / splitCols) * (splitCols - 1);
      }
      return width;
    }(size.width);
    return Scaffold(
      body: size.width > 767
        ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: autocompleteProduct(containerWidth),
                  ),
                  ProductList(
                    list: list,
                    loadProducts: loadProducts,
                    size: size
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size.width - containerWidth,
              child: DetailBox(receipt: receipt, loadProducts: loadProducts)
            )
          ],
        )
      : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: autocompleteProduct(containerWidth),
          ),
          ProductList(
            list: list,
            loadProducts: loadProducts,
            size: size,
          ),
          DetailBox(receipt: receipt, loadProducts: loadProducts)
        ],
      ),
    );
  }

  Autocomplete<Product> autocompleteProduct(double containerWidth) {
    late TextEditingController textEditingController;
    return Autocomplete<Product>(
      displayStringForOption:(Product option) {
        return '${option.name}, ${option.code}';
      },
      optionsBuilder: (TextEditingValue textEditingValue) async {
        String sql = 'SELECT * FROM products';
        List<Object?> params = [];
        
        if (textEditingValue.text.isNotEmpty) {
          sql += ' WHERE (name LIKE ? OR code=?)';
          params.add('%${textEditingValue.text}%');
          params.add(textEditingValue.text);
        }
        sql += ' ORDER BY name LIMIT 50';
        List<Product> products = await Product.query(sql, params: params);
        return products;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted
        ) {
        textEditingController = fieldTextEditingController;
        return TextFormField(
          controller: fieldTextEditingController,
          decoration: const InputDecoration(
            labelText: 'Search',
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0))
            )
          ),
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200, maxWidth: containerWidth - 16),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: options.length,
              shrinkWrap: false,
              itemBuilder: (BuildContext context, int index) {
                final Product option = options.elementAt(index);
                return InkWell(
                  onTap: () => onSelected(option),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('${option.name}, ${option.code}'),
                  ),
                );
              },
            )
          ),
        ),
      ),// */
      onSelected: (Product selection) async {
        await receipt.addProduct(selection.toMap());
        list = await receipt.products();
        setState(() {});

        Timer(const Duration(microseconds: 20), () {
          primaryFocus!.unfocus();
          textEditingController.text = '';
        });
      },
    );
  }
}

class DetailBox extends StatelessWidget {
  final TaxReceipt receipt;
  final Function loadProducts;
  const DetailBox({super.key, required this.receipt, required this.loadProducts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: const BorderRadius.all(Radius.circular(6.0))
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total fara TVA', style: TextStyle(color: Colors.white),),
                      Text(receipt.totalWithoutVat.toStringAsFixed(receipt.precision), style: const TextStyle(color: Colors.white),),
                    ],
                  ),
                  const SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total TVA', style: TextStyle(color: Colors.white),),
                      Text(receipt.totalVat.toStringAsFixed(receipt.precision), style: const TextStyle(color: Colors.white),),
                    ],
                  ),
                  const SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(color: Colors.white),),
                      Text(receipt.total.toStringAsFixed(receipt.precision), style: const TextStyle(color: Colors.white),),
                    ],
                  ),
                  const SizedBox(height: 10.0,),
                ],
              ),
            )
          ),
          const SizedBox(height: 8.0,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Issue', style: TextStyle(fontSize: 20.0),),
                  ),
                  onPressed: () async {
                    if (receipt.total == 0.00) {
                      messageModal(context, Message(title: 'Error', text: 'Add some products!', type: MessageType.error));
                      return;
                    }

                    SerialPort port = SerialPort('COM1');
                    DatecsDriver driver = DatecsDriver(port);
                    bool isPrinted = await driver.print(receipt);
                    if (isPrinted) {
                      receipt.isNew = false;
                      await receipt.save();
                      await loadProducts();
                    }
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final List<TaxReceiptProduct> list;
  final Function loadProducts;
  final Size size;

  const ProductList({
    super.key,
    required this.list,
    required this.loadProducts,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          TaxReceiptProduct item = list[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.keyboard_arrow_right),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: size.width > 400 ? 150 : (size.width - 150),
                          child: Text('${item.name}, ${item.code}', maxLines: 2),
                        ),
                        Text(
                          '${item.quantity.toStringAsFixed(2)} x ${item.priceWithVat.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                    size.width > 767 ? Row(
                      children: [
                        Text(item.total.toStringAsFixed(2)),
                        const SizedBox(width: 10,),
                        SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(width: 1,),
                              GestureDetector(
                                child: const Icon(Icons.remove_circle),
                                onTap:() async {
                                  if (item.quantity <= 1) {
                                    return;
                                  }
                                  item.quantity--;
                                  await item.save();
                                  await loadProducts();
                                },
                              ),
                              Text(item.quantity.toStringAsFixed(2)),
                              GestureDetector(
                                child: const Icon(Icons.add_circle),
                                onTap:() async {
                                  item.quantity++;
                                  await item.save();
                                  await loadProducts();
                                },
                              ),
                              const SizedBox(width: 1,),
                            ],
                          ),
                        )
                      ],
                    )
                    : Container()
                  ]
                ),
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
            ),
          );
        }
      ),
    );
  }
}

void productModal(BuildContext context, TaxReceiptProduct product, Function fn) {}

Future<void> messageModal(BuildContext context, Message message) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        title: Text(message.title),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message.text),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Ok'),
            onPressed: () async {
              // close modal
              Navigator.pop(context);
            }
          ),
        ],
      );
    }
  );
}

class Message {
  String title;
  String text;
  MessageType type;
  Message({
    required this.title,
    required this.text,
    this.type = MessageType.success
  });
}
enum MessageType {
    success,
    error,
  }