import 'package:cash_register/models/docs/tax_receipt_product.dart';
import 'package:cash_register/services/model.dart';
import 'package:cash_register/services/database.dart';
// import 'package:intl/intl.dart';

class TaxReceipt extends Model {
  int clientId;
  String issueDate;
  String seriesName;
  int precision;
  String currency;
  double exchangeRate;
  int workStationId;
  double total;
  double totalWithoutVat;
  double totalVat;
  bool isNew;

  @override
  String tableName = 'tax_receipts';
  
  @override
  int? id;
  
  TaxReceipt({
    this.id,
    this.clientId = 0,
    required this.issueDate, // DateFormat('yyyy-MM-dd').format(DateTime.now()),
    required this.workStationId,
    this.seriesName = 'BF',
    this.precision = 2,
    this.currency = 'RON',
    this.exchangeRate = 1.0,
    this.total = 0.0,
    this.totalWithoutVat = 0.0,
    this.totalVat = 0.0,
    this.isNew = false,
  });

  TaxReceipt.fromMap(Map<String, dynamic> item):
    id = item['id'],
    clientId = item['clientId'],
    issueDate = item['issueDate'],
    workStationId = item['workStationId'],
    seriesName = item['seriesName'],
    precision = item['precision'],
    currency = item['currency'],
    exchangeRate = item['exchangeRate'] is String ? double.parse(item['exchangeRate']) : item['exchangeRate'],
    total = item['total'] is String ? double.parse(item['total']) : item['total'],
    totalWithoutVat = item['totalWithoutVat'] is String ? double.parse(item['totalWithoutVat']) : item['totalWithoutVat'],
    totalVat = item['totalVat'] is String ? double.parse(item['totalVat']) : item['totalVat'],
    isNew = item['isNew'] is bool ? item['isNew'] : (item['isNew'] == 'true' || item['isNew'] == 1);

  Future<int> addProduct(Map<String, dynamic> map) async {
    map['taxReceiptId'] = id;
    map['productId'] = map['id'];
    map['id'] = null;
    TaxReceiptProduct product = TaxReceiptProduct.fromMap(map);
    int result = await product.save();
    await updateData();
    return result;
  }

  Future<void> updateData() async {
    List<TaxReceiptProduct> products = await this.products();
    total            = 0.0;
    totalWithoutVat  = 0.0;
    totalVat         = 0.0;
    for (TaxReceiptProduct product in products) {
      total           += product.total;
      totalWithoutVat += product.totalWithoutVat;
      totalVat        += product.totalVat;
    }
    total           = round(total, 2);
    totalWithoutVat = round(totalWithoutVat, 2);
    totalVat        = round(totalVat, 2);
    await save();
    print(toMap());
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'issueDate': issueDate,
      'workStationId': workStationId,
      'seriesName': seriesName,
      'precision': precision,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'total': total,
      'totalWithoutVat': totalWithoutVat,
      'totalVat': totalVat,
      'isNew': isNew,
    };
  }

  Future<List<TaxReceiptProduct>> products() async {
    return TaxReceiptProduct.query(
      'SELECT * FROM tax_receipts_products WHERE taxReceiptId = ?',
      params: [id]
    );
  }

  static Future<TaxReceipt> find(int id) async {
    final Map<String, dynamic>? map = await DatabaseService.query(
          'SELECT * FROM tax_receipts WHERE id=?',
          params: [id],
          singleResult: true);
    if (map == null) {
      throw Exception('No results font for id $id');
    }
    return TaxReceipt.fromMap(map);
  }

  static Future<List<TaxReceipt>> query(String sql, {
      List<Object?> params = const []
    }) async {
    final List? list = await DatabaseService.query(sql, params: params);
    final List<TaxReceipt> results = [];
    if (list != null) {
      for (final row in list) {
        results.add(TaxReceipt.fromMap(row));
      }
    }
    return results;
  }
}