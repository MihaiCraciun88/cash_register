import 'package:cash_register/services/database.dart';
import 'package:cash_register/services/model.dart';
import 'package:sqlite_wrapper/sqlite_wrapper.dart';

class Product extends Model {
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

  @override
  String tableName = 'products';

  Product({
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
  });

  Product.fromMap(Map<String, dynamic> item): 
    id = item['id'],
    name = item['name'],
    code = item['code'],
    description = item['description'],
    measuringUnit = item['measuringUnit'],
    productType = item['productType'],
    price = double.parse(item['price']),
    currency = item['currency'],
    vatName = item['vatName'],
    vatPercentage = item['vatPercentage'],
    vatIncluded = item['vatIncluded'] == 1;
  
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
    };
  }

  static Future<Product> find(int id) async {
    final Map<String, dynamic>? map = await DatabaseService.query(
          'SELECT * FROM products WHERE id=?',
          params: [id],
          singleResult: true);
    if (map == null) {
      throw Exception('No results font for id $id');
    }
    return Product.fromMap(map);
  }

  static Future<List<Product>> query(String sql, {
      List<Object?> params = const []
    }) async {
    final List? list = await DatabaseService.query(sql, params: params);
    final List<Product> results = [];
    if (list != null) {
      for (final row in list) {
        results.add(Product.fromMap(row));
      }
    }
    return results;
  }
}