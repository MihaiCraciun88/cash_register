

import 'dart:math';

import 'package:cash_register/models/docs/tax_receipt.dart';
import 'package:cash_register/models/docs/tax_receipt_product.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key, required this.title, required this.navigatorKey})
      : super(key: key);
  final String title;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<TaxReceipt> list = [];

  @override
  void initState() {
    super.initState();
    loadList();
  }

  Future<void> loadList() async {
    String sql = 'SELECT * FROM tax_receipts WHERE isNew=0 ORDER BY id DESC';
    List<TaxReceipt> receipts = await TaxReceipt.query(sql);
    setState(() {
      list = receipts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            TaxReceipt receipt = list.elementAt(index);
            return Card(
              child: ListTile(
                title: Text('${receipt.seriesName} ${receipt.id}'),
                subtitle: Text('${receipt.total} ${receipt.currency}'),
                onTap: () async {
                  List<TaxReceiptProduct> products = await receipt.products();
                  taxReceiptModal(context, receipt, products);
                },
              ),
            );
          }
        ),
      )
    );
  }
}

Future<void> taxReceiptModal(
    BuildContext context,
    TaxReceipt receipt,
    List<TaxReceiptProduct> products
  ) {
  Size size = MediaQuery.of(context).size;
  double containerWidth = size.width > 767 ? (size.width / 3) : (size.width - 100);
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        title: Text('Tax receipt ${receipt.seriesName} ${receipt.id}'),
        content: Column(
          children: [
            SizedBox(
              width: containerWidth,
              height: min(size.height / 3, products.length * 40.0),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (BuildContext context, int index) {
                  TaxReceiptProduct product = products[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product.name),
                        Text('${product.quantity} x ${product.priceWithVat.toStringAsFixed(2)}'),
                      ],
                    ),
                  );
                }
              ),
            ),
            SizedBox(
              width: containerWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  Text(receipt.total.toStringAsFixed(2)),
                ],
              ),
            )
          ],
        ),
        actions: [
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context)
          ),
          ElevatedButton(
            child: const Text('Issue'),
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