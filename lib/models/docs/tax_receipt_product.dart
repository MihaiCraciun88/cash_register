import 'package:cash_register/models/docs/tax_receipt.dart';
import 'package:cash_register/services/model.dart';
import 'package:cash_register/services/database.dart';
import 'package:cash_register/models/product.dart';

class TaxReceiptProduct extends Model {
  @override
  int? id;
  String name;
  String code;
  String description;
  String measuringUnit;
  String productType;
  double price;
  String currency;
  String vatName;
  int vatPercentage;
  bool vatIncluded;
  double quantity;
  int taxReceiptId;
  int productId;
  
  @override
  String tableName = 'tax_receipts_products';

  TaxReceiptProduct({
    this.id,
    required this.name,
    this.code = '',
    this.description = '',
    this.measuringUnit = 'buc',
    this.productType = 'Serviciu',
    this.price = 0.0,
    this.currency = 'RON',
    this.vatName = 'Normala',
    this.vatPercentage = 19,
    this.vatIncluded = true,
    this.quantity = 1.0,
    required this.taxReceiptId,
    required this.productId,
  });

  TaxReceiptProduct.fromMap(Map<String, dynamic> item): 
    id = item['id'],
    name = item['name'],
    code = item['code'],
    description = item['description'],
    measuringUnit = item['measuringUnit'],
    productType = item['productType'],
    price = item['price'] is String ? double.parse(item['price']) : item['price'],
    currency = item['currency'],
    vatName = item['vatName'],
    vatPercentage = item['vatPercentage'] is String ? int.parse(item['vatPercentage']) : item['vatPercentage'],
    vatIncluded = item['vatIncluded'] is bool ? item['vatIncluded'] : (item['vatIncluded'] == 'true' || item['vatIncluded'] == 1),
    quantity = item['quantity'] is String ? double.parse(item['quantity']) : item['quantity'] ?? 1.0,
    taxReceiptId = item['taxReceiptId'],
    productId = item['productId'];
  
  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'measuringUnit': measuringUnit,
      'productType': productType,
      'price': price,
      'currency': currency,
      'vatName': vatName,
      'vatPercentage': vatPercentage,
      'vatIncluded': vatIncluded,
      'quantity': quantity,
      'taxReceiptId': taxReceiptId,
      'productId': productId,
    };
  }

  double get priceWithVat {
    if (vatIncluded) {
      return price;
    }
    return round(price * ((100 + vatPercentage) / 100), 2);
  }

  double get priceWithoutVat {
    if (vatIncluded) {
      return round(price / ((100 + vatPercentage) / 100), 4);
    }
    return price;
  }

  double get priceVat {
    return round(priceWithVat - priceWithoutVat, 2);
  }

  double get total {
    return round(priceWithVat * quantity, 2); 
  }

  double get totalWithoutVat {
    return round(priceWithoutVat * quantity, 2); 
  }

  double get totalVat {
    return round(total - totalWithoutVat, 2); 
  }

  @override
  Future<int> delete() async {
    int result = await super.delete();
    TaxReceipt receipt = await doc();
    await receipt.updateData();
    return result;
  }

  @override
  Future<int> update() async {
    int result = await super.update();
    TaxReceipt receipt = await doc();
    await receipt.updateData();
    return result;
  }

  Future<Product> product() async {
    return Product.find(productId);
  }

  Future<TaxReceipt> doc() async {
    return TaxReceipt.find(taxReceiptId);
  }

  static Future<TaxReceiptProduct> find(int id) async {
    final Map<String, dynamic>? map = await DatabaseService.query(
          'SELECT * FROM tax_receipts_products WHERE id=?',
          params: [id],
          singleResult: true);
    if (map == null) {
      throw Exception('No results font for id $id');
    }
    return TaxReceiptProduct.fromMap(map);
  }

  static Future<List<TaxReceiptProduct>> query(String sql, {
      List<Object?> params = const []
    }) async {
    final List? list = await DatabaseService.query(sql, params: params);
    final List<TaxReceiptProduct> results = [];
    if (list != null) {
      for (final row in list) {
        results.add(TaxReceiptProduct.fromMap(row));
      }
    }
    return results;
  }
}