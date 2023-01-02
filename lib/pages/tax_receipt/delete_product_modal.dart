import 'package:cash_register/services/database.dart';
import 'package:cash_register/models/docs/tax_receipt_product.dart';
import 'package:flutter/material.dart';

Future<void> deleteProductModal(BuildContext context, TaxReceiptProduct product, Function fn) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        title: const Text('Delete product'),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Are you sure you want to delete product "${product.name}"?'),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context)
          ),
          ElevatedButton(
            child: const Text('Delete'),
            onPressed: () async {
              // close modal
              Navigator.pop(context);

              // delete product
              await product.delete();

              // callback
              fn();
            }
          ),
        ],
      );
    }
  );
}