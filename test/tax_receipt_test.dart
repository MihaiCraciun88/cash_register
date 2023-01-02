import 'package:cash_register/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cash_register/models/docs/tax_receipt.dart';
import 'package:cash_register/models/docs/tax_receipt_product.dart';
import 'package:intl/intl.dart';
import 'package:cash_register/services/database.dart';


void main() async {
  TaxReceipt receipt = TaxReceipt(
    issueDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    workStationId: 0,
    isNew: true,
  );

  await DatabaseService.init();

  test('TaxReceipt', () async {
    await receipt.save();
    int id = receipt.id ?? 0;
    await receipt.save();
    expect(id, receipt.id);
  });

  test('DELETE', () async {
    DatabaseService.query('DELETE FROM tax_receipts');
    DatabaseService.query('DELETE FROM tax_receipts_products');
    expect((await TaxReceipt.query('SELECT * FROM tax_receipts')).length, 0);
    expect((await TaxReceipt.query('SELECT * FROM tax_receipts_products')).length, 0);
  });
}