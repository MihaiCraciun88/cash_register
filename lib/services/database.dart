import 'dart:io';

import 'package:sqlite_wrapper/sqlite_wrapper.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static DatabaseInfo? info;

  static Future<DatabaseInfo> init() async {
    var databasesPath = 'database.db';
    if (Platform.isAndroid) {
      Directory appDir = await getApplicationSupportDirectory();
      databasesPath = '${appDir.path}/database.db';
    }
    // SQLiteWrapper().debugMode = true;
    info ??= await SQLiteWrapper().openDB(
        databasesPath,
        onCreate: () async {
          SQLiteWrapper().execute(
            '''CREATE TABLE products(
              id INTEGER PRIMARY KEY,
              name TEXT,
              code TEXT,
              description TEXT,
              measuringUnit TEXT,
              price TEXT,
              currency TEXT,
              productType TEXT,
              vatName TEXT,
              vatPercentage INTEGER,
              vatIncluded INTEGER
            )''',
          );
          SQLiteWrapper().execute(
            '''CREATE TABLE tax_receipts(
              id INTEGER PRIMARY KEY,
              clientId INTEGER,
              issueDate TEXT,
              seriesName TEXT,
              precision INTEGER,
              currency TEXT,
              exchangeRate TEXT,
              workStationId INTEGER,
              total TEXT,
              totalWithoutVat TEXT,
              totalVat TEXT,
              isNew INTEGER
            )''',
          );
          SQLiteWrapper().execute(
            '''CREATE TABLE tax_receipts_products(
              id INTEGER PRIMARY KEY,
              name TEXT,
              code TEXT,
              description TEXT,
              measuringUnit TEXT,
              price TEXT,
              currency TEXT,
              productType TEXT,
              vatName TEXT,
              vatPercentage INTEGER,
              vatIncluded INTEGER,
              quantity TEXT,
              taxReceiptId INTEGER,
              productId INTEGER,
              FOREIGN KEY (taxReceiptId) 
                  REFERENCES tax_receipts (id) 
                      ON DELETE CASCADE 
                      ON UPDATE NO ACTION
            )''',
          );
        },
        version: 1,
      );
      return info!;
  }

  static Future<dynamic> query(String sql, {
    List<Object?> params = const [],
    dynamic Function(Map<String, dynamic>)? fromMap,
    bool singleResult = false,
    String? dbName,
  }) async {
    if (info == null) {
      await init();
    }
    return SQLiteWrapper().query(sql, params: params, fromMap: fromMap,
      singleResult: singleResult, dbName: dbName);
  }

  static void close() {
    return SQLiteWrapper().closeDB();
  }
}