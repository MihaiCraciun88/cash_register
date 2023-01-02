import 'dart:math';

import 'package:sqlite_wrapper/sqlite_wrapper.dart';

abstract class Model {
  abstract int? id;
  abstract String tableName;

  Map<String, Object?> toMap();

  Future<int> insert() async {
    int result = await SQLiteWrapper().insert(toMap(), tableName);
    id = result;
    return result;
  }

  Future<int> update() async {
    return SQLiteWrapper().update(toMap(), tableName, keys: ['id']);
  }

  Future<int> save() async {
    if (id == null) {
      id = await insert();
    } else {
      await update();
    }
    return id!;
  }

  Future<int> delete() async {
    return SQLiteWrapper().delete(toMap(), tableName, keys: ['id']);
  }

  double round(double val, int places) { 
    num mod = pow(10.0, places); 
    return ((val * mod).round().toDouble() / mod); 
  }
}