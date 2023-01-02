

import 'package:cash_register/models/product.dart';

class Vat {
  int? id;
  String name;
  int perventage;
  Vat(this.id, this.name, this.perventage);

  @override
  int get hashCode => Object.hash(id, name, perventage);

  @override
  bool operator ==(Object other) {
      if (identical(this, other)) {
        return true;
      }
      if (other.runtimeType != runtimeType) {
        return false;
      }
      return other is Vat && other.id == id;
  }

  static List<Vat> list() {
    List<Vat> list = [];
    list.add(Vat(1, 'Normala', 19));
    list.add(Vat(2, 'Redusa', 9));
    list.add(Vat(3, 'Redusa', 5));
    list.add(Vat(4, 'SDD', 0));
    list.add(Vat(5, 'SFDD', 0));
    return list;
  }

  static Vat? find(int vatId) {
    List<Vat> list = Vat.list();
    for (final Vat vat in list) {
      if (vat.id == vatId) {
        return vat;
      }
    }
    return null;
  }

  static Vat findByProduct(Product product) {
    List<Vat> list = Vat.list();
    for (final Vat vat in list) {
      if (product.vatName.isNotEmpty && product.vatName != vat.name) {
        continue;
      }
      if (vat.perventage == product.vatPercentage) {
        return vat;
      }
    }
    return list.first;
  }
}